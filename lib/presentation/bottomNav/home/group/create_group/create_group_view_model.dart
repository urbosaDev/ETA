import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/group_model.dart';
import 'package:what_is_your_eta/data/model/message_model.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/fcm_repository.dart';
import 'package:what_is_your_eta/data/repository/group_repository.dart';

import 'package:what_is_your_eta/data/repository/user_%08repository.dart';
import 'package:what_is_your_eta/presentation/models/friend_info_model.dart';

class CreateGroupViewModel extends GetxController {
  final GroupRepository _groupRepository;
  final UserRepository _userRepository;
  final AuthRepository _authRepository;
  final FcmRepository _fcmRepository;
  CreateGroupViewModel({
    required GroupRepository groupRepository,
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required FcmRepository fcmRepository,
  }) : _groupRepository = groupRepository,
       _authRepository = authRepository,
       _userRepository = userRepository,
       _fcmRepository = fcmRepository;

  // init 했을때 내 userModel 가져와야함
  final Rx<UserModel?> userModel = Rx<UserModel?>(null);

  final RxList<FriendInfoModel> friendList = <FriendInfoModel>[].obs;

  StreamSubscription<UserModel>? _userSub;

  final RxList<FriendInfoModel> selectedFriends = <FriendInfoModel>[].obs;

  final RxBool isCreating = false.obs;
  void toggleFriend(FriendInfoModel friend) {
    if (selectedFriends.any((f) => f.userModel.uid == friend.userModel.uid)) {
      selectedFriends.removeWhere(
        (f) => f.userModel.uid == friend.userModel.uid,
      );
    } else {
      selectedFriends.add(friend);
    }
  }

  final RxString groupTitle = ''.obs;

  List<FriendInfoModel> get validFriends =>
      friendList
          .where(
            (f) =>
                f.userModel.uniqueId != 'unknown' && !f.isBlocked, // 차단한 유저는 제외
          )
          .toList();

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
    final users = await _userRepository.getUsersByUids(uids);
    final blockedUids = userModel.value?.blockedUids ?? [];

    friendList.value =
        users.map((user) {
          final isBlocked = blockedUids.contains(user.uid);
          return FriendInfoModel(userModel: user, isBlocked: isBlocked);
        }).toList();
  }

  final RxBool isGroupCreated = false.obs;
  // 그룹 만들기 메서드
  Future<bool> createGroup() async {
    final currentUser = userModel.value?.uid;
    if (isCreating.value) return false;
    if (currentUser == null || !isReadyToCreate) return false;

    isCreating.value = true;

    final finalSelectedUid = [
      currentUser,
      ...selectedFriends.map((u) => u.userModel.uid),
    ];

    final group = GroupModel(
      id: '',
      createrId: currentUser,
      title: groupTitle.value,
      memberIds: finalSelectedUid,
      chatRoomId: '',
      currentPromiseId: null,
      endPromiseIds: [],
      createdAt: DateTime.now(),
    );

    try {
      final groupId = await _groupRepository.createGroup(group);
      if (groupId.isEmpty) return false;

      for (final uid in finalSelectedUid) {
        await _userRepository.addGroupId(uid, groupId);
      }

      await _groupRepository.sendGroupMessage(
        groupId,
        SystemMessageModel(text: '채팅방이 생성되었습니다', sentAt: DateTime.now()),
      );

      final otherUids = finalSelectedUid.where((uid) => uid != currentUser);
      final tokenUidPairs = <Map<String, String>>[];
      for (final uid in otherUids) {
        final tokens = await _userRepository.getFcmTokens(uid);
        for (final token in tokens) {
          tokenUidPairs.add({'token': token, 'uid': uid});
        }
      }

      if (tokenUidPairs.isNotEmpty) {
        await _fcmRepository.sendGroupNotification(
          targetTokens: tokenUidPairs,
          groupName: groupTitle.value,
          message: '그룹이 생성되었습니다',
          groupId: groupId,
        );
      }

      return true;
    } catch (e) {
      debugPrint('❌ 그룹 생성 실패: $e');
      return false;
    } finally {
      isCreating.value = false;
    }
  }

  // 로직 생각해봐야 하는 것
  // init시에 getCurrentUser로 uid를 가져온다.
  // 그 uid로 streamUser를 통해 userModel을 가져온다.
  // 그 userModel을 통해 친구 리스트를 가져온다.
  // 친구 리스트를 통해 친구를 선택할 수 있는 화면을 띄운다.

  // 친구들 전부 업데이트 해야함
}
