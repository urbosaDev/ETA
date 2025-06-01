import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/group_model.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/group_repository.dart';

import 'package:what_is_your_eta/data/repository/user_%08repository.dart';

class CreateGroupViewModel extends GetxController {
  final GroupRepository _groupRepository;
  final UserRepository _userRepository;
  final AuthRepository _authRepository;
  CreateGroupViewModel({
    required GroupRepository groupRepository,
    required AuthRepository authRepository,
    required UserRepository userRepository,
  }) : _groupRepository = groupRepository,
       _authRepository = authRepository,
       _userRepository = userRepository;

  // init 했을때 내 userModel 가져와야함
  final Rx<UserModel?> userModel = Rx<UserModel?>(null);

  final RxList<UserModel> _friendList = <UserModel>[].obs;
  List<UserModel> get friendList => _friendList;

  StreamSubscription<UserModel>? _userSub;

  final RxList<UserModel> selectedFriends = <UserModel>[].obs;

  void toggleFriend(UserModel user) {
    if (selectedFriends.any((u) => u.uid == user.uid)) {
      selectedFriends.removeWhere((u) => u.uid == user.uid);
    } else {
      selectedFriends.add(user);
    }
  }

  final RxString groupTitle = ''.obs;

  bool get isReadyToCreate =>
      groupTitle.isNotEmpty && selectedFriends.isNotEmpty;

  void onTitleChanged(String value) {
    groupTitle.value = value.trim();
  }

  @override
  void onInit() {
    super.onInit();
    _initUser();
  }

  @override
  void onClose() {
    _userSub?.cancel(); // 꼭 해줘야 메모리 누수 방지됨
    super.onClose();
    debugPrint('🗑️ LoungeInGroupViewModel deleted');
  }

  void _initUser() async {
    final user = _authRepository.getCurrentUser();
    if (user != null) {
      _startUserStream(user.uid);
      getUsersByUids(userModel.value?.friendsUids ?? []);
    } else {
      // 로그아웃 처리 또는 에러 처리 필요
    }
  }

  void _startUserStream(String uid) {
    _userSub = _userRepository.streamUser(uid).listen((user) {
      userModel.value = user;
      getUsersByUids(user.friendsUids);
    });
  }

  Future<void> getUsersByUids(List<String> uids) async {
    _friendList.value = await _userRepository.getUsersByUids(uids);
  }

  final RxBool isGroupCreated = false.obs;
  // 그룹 만들기 메서드
  Future<void> createGroup() async {
    // isReadyToCreate가 true일때만 실행
    final currentUser = userModel.value?.uid;

    if (currentUser == null) return;
    if (!isReadyToCreate) return;
    final finalSelectedUid = [
      currentUser,
      ...selectedFriends.map((u) => u.uid),
    ];
    // GroupModel 생성
    final group = GroupModel(
      id: '',
      title: groupTitle.value,
      memberIds: finalSelectedUid,
      chatRoomId: '',
      promiseIds: [],
      createdAt: DateTime.now(),
    );
    final groupId = await _groupRepository.createGroup(group);
    for (final user in finalSelectedUid) {
      // 각 유저의 groupId에 추가
      await _userRepository.addGroupId(user, groupId);
    }
    if (groupId.isNotEmpty) {
      // 그룹 생성 성공
      isGroupCreated.value = true;
    }
  }

  // 로직 생각해봐야 하는 것
  // init시에 getCurrentUser로 uid를 가져온다.
  // 그 uid로 streamUser를 통해 userModel을 가져온다.
  // 그 userModel을 통해 친구 리스트를 가져온다.
  // 친구 리스트를 통해 친구를 선택할 수 있는 화면을 띄운다.

  // 친구들 전부 업데이트 해야함
}
