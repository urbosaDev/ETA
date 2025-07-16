import 'dart:async';

import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/group_model.dart';
import 'package:what_is_your_eta/data/model/location_model/promise_location_model.dart';
import 'package:what_is_your_eta/data/model/promise_model.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/data/repository/notification_api_repository.dart';
import 'package:what_is_your_eta/data/repository/group_repository.dart';
import 'package:what_is_your_eta/data/repository/promise_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';
import 'package:what_is_your_eta/presentation/core/filter_words.dart';

class CreatePromiseViewModel extends GetxController {
  final String groupId;
  final GroupRepository _groupRepository;
  final UserRepository _userRepository;
  final PromiseRepository _promiseRepository;
  final NotificationApiRepository _fcmRepository;
  CreatePromiseViewModel({
    required this.groupId,
    required GroupRepository groupRepository,
    required UserRepository userRepository,
    required PromiseRepository promiseRepository,
    required NotificationApiRepository fcmRepository,
  }) : _groupRepository = groupRepository,
       _userRepository = userRepository,
       _promiseRepository = promiseRepository,
       _fcmRepository = fcmRepository;

  final Rx<GroupModel?> groupModel = Rx<GroupModel?>(null);
  final RxList<UserModel> memberList = <UserModel>[].obs;

  final RxSet<String> selectedMemberIds = <String>{}.obs;

  final RxBool isLoading = true.obs;
  final RxBool isMemberFetchLoading = false.obs;
  final RxString promiseName = ''.obs;
  final RxBool containsBlockedWordInName = false.obs;
  StreamSubscription<GroupModel>? _groupSub;
  final Rx<DateTime?> promiseTime = Rx<DateTime?>(null);
  final Rx<PromiseLocationModel?> selectedLocation = Rx<PromiseLocationModel?>(
    null,
  );
  void setPromiseTime(DateTime time) {
    promiseTime.value = time;
  }

  void onPromiseNameChanged(String value) {
    promiseName.value = value.trim();
    containsBlockedWordInName.value = FilterWords.containsBlockedWord(
      promiseName.value,
    );
  }

  final RxBool isFormValid = false.obs;

  final RxBool isNameValid = false.obs;
  final RxBool isMembersValid = false.obs;
  final RxBool isLocationValid = false.obs;
  final RxBool isTimeValid = false.obs;

  void validateForm() {
    isNameValid.value = promiseName.value.isNotEmpty;
    isMembersValid.value = selectedMemberIds.isNotEmpty;
    isLocationValid.value = selectedLocation.value != null;
    isTimeValid.value = promiseTime.value != null;

    isFormValid.value =
        isNameValid.value &&
        isMembersValid.value &&
        isLocationValid.value &&
        isTimeValid.value;
  }

  @override
  void onInit() {
    super.onInit();
    _initialize();
    ever(promiseName, (_) => validateForm());
    ever(selectedLocation, (_) => validateForm());
    ever(promiseTime, (_) => validateForm());
    ever(selectedMemberIds, (_) => validateForm());
  }

  @override
  void onClose() {
    _groupSub?.cancel();
    super.onClose();
  }

  Future<void> _initialize() async {
    isLoading.value = true;
    groupModel.value = await _groupRepository.getGroup(groupId);
    if (groupModel.value != null) {
      _startGroupStream();
      fetchMembers(groupModel.value!.memberIds);
    }
    isLoading.value = false;
  }

  void _startGroupStream() {
    _groupSub = _groupRepository.streamGroup(groupId).listen((group) {
      groupModel.value = group;
      fetchMembers(group.memberIds);
    });
  }

  Future<void> fetchMembers(
    List<String> memberIds, {
    bool clearSelection = false,
  }) async {
    isMemberFetchLoading.value = true;
    final members = await _userRepository.getUsersByUids(memberIds);
    memberList.value = members;
    isMemberFetchLoading.value = false;
    if (clearSelection) {
      selectedMemberIds.clear();
    }
  }

  void toggleMember(UserModel member) {
    if (selectedMemberIds.contains(member.uid)) {
      selectedMemberIds.remove(member.uid);
    } else {
      selectedMemberIds.add(member.uid);
    }
  }

  bool isMemberSelected(UserModel member) {
    return selectedMemberIds.contains(member.uid);
  }

  void setSelectedLocation(PromiseLocationModel location) {
    selectedLocation.value = location;
  }

  final RxBool isPromiseCreated = false.obs;
  final RxString systemMessage = ''.obs;
  final RxBool isCreatingPromise = false.obs;
  Future<void> createPromise() async {
    try {
      if (!isFormValid.value) {
        systemMessage.value = '약속 정보를 모두 올바르게 입력해주세요.';
        isPromiseCreated.value = false;
        return;
      }

      isPromiseCreated.value = false;
      isCreatingPromise.value = true;
      final promise = PromiseModel(
        id: '',
        groupId: groupId,
        name: promiseName.value,
        memberIds: selectedMemberIds.toList(),
        location: selectedLocation.value!,
        time: promiseTime.value!,

        arriveUserIds: [],
        userLocations: null,

        notify1HourScheduled: false,
        notifyStartScheduled: false,
      );

      final createdId = await _promiseRepository.createPromise(promise);
      await _groupRepository.addPromiseIdToGroup(
        groupId: groupId,
        promiseId: createdId,
      );

      try {
        final memberUids = selectedMemberIds.toList();

        if (memberUids.isNotEmpty) {
          _fcmRepository.sendPromiseNotification(
            targetUserIds: memberUids,
            title: '${groupModel.value?.title ?? '그룹'} 약속 생성',
            body: '${promiseName.value} 약속이 생성되었습니다!',
            groupId: groupId,
          );
        }
      } catch (_) {}
      systemMessage.value = '약속이 성공적으로 생성되었습니다.';
      isPromiseCreated.value = true;
    } catch (_) {
      systemMessage.value = '약속 생성 중 오류가 발생했습니다';
      isPromiseCreated.value = false;
    } finally {
      isCreatingPromise.value = false;
    }
  }
}
