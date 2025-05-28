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
  StreamSubscription<GroupModel>? _groupSub;
  final RxList<UserModel> memberList = <UserModel>[].obs;
  final RxBool isLoading = true.obs;
  @override
  void onInit() {
    super.onInit();
    // 초기화 로직이 필요하다면 여기에 작성
    _initialize();
  }

  @override
  void onClose() {
    _groupSub?.cancel();
    super.onClose();
  }

  Future<void> _initialize() async {
    isLoading.value = true;
    // 시작시에 그룹을 fetch, 이후는 stream
    groupModel.value = await _groupRepository.getGroup(groupId);
    if (groupModel.value != null) {
      _startGroupStream();
      fetchMembers(groupModel.value!.memberIds);
    }
    isLoading.value = false;
  }

  // 그룹을 stream,
  void _startGroupStream() {
    _groupSub = _groupRepository.streamGroup(groupId).listen((group) {
      groupModel.value = group;
      fetchMembers(group.memberIds);
    });
  }

  // 그룹 내의 멤버를 fetch 하기 위함
  Future<void> fetchMembers(List<String> memberIds) async {
    final members = await _userRepository.getUsersByUids(memberIds);
    memberList.value = members;
  }
}
