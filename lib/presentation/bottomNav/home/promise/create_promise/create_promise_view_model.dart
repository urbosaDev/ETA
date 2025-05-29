import 'dart:async';

import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/group_model.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/data/repository/group_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';

class CreatePromiseViewModel extends GetxController {
  final String groupId;
  final GroupRepository _groupRepository;
  final UserRepository _userRepository;

  CreatePromiseViewModel({
    required this.groupId,
    required GroupRepository groupRepository,
    required UserRepository userRepository,
  }) : _groupRepository = groupRepository,
       _userRepository = userRepository;

  final Rx<GroupModel?> groupModel = Rx<GroupModel?>(null);
  final RxList<UserModel> memberList = <UserModel>[].obs;

  final RxSet<String> selectedMemberIds = <String>{}.obs;

  final RxBool isLoading = true.obs;
  final RxBool isMemberFetchLoading = false.obs;
  final RxString promiseName = ''.obs;

  StreamSubscription<GroupModel>? _groupSub;
  final Rx<DateTime?> promiseTime = Rx<DateTime?>(null);

  void setPromiseTime(DateTime time) {
    promiseTime.value = time;
  }

  @override
  void onInit() {
    super.onInit();
    _initialize();
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

  Future<void> fetchMembers(List<String> memberIds) async {
    isMemberFetchLoading.value = true;
    final members = await _userRepository.getUsersByUids(memberIds);
    memberList.value = members;
    isMemberFetchLoading.value = false;
    selectedMemberIds.clear();
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
}
