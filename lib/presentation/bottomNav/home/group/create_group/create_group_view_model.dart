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

    // 그룹 생성
    final groupId = await _groupRepository.createGroup(group);

    // 각 유저의 groupId 업데이트
    for (final user in finalSelectedUid) {
      await _userRepository.addGroupId(user, groupId);
    }

    if (groupId.isNotEmpty) {
      final systemMessage = SystemMessageModel(
        text: '채팅방이 생성되었습니다',
        sentAt: DateTime.now(),
      );

      await _groupRepository.sendGroupMessage(groupId, systemMessage);
      // FCM 발송

      try {
        final otherUids =
            finalSelectedUid.where((uid) => uid != currentUser).toList();

        final allTokens = <String>[];

        for (final uid in otherUids) {
          final tokens = await _userRepository.getFcmTokens(uid);
          allTokens.addAll(tokens);
        }

        if (allTokens.isNotEmpty) {
          await _fcmRepository.sendGroupNotification(
            targetTokens: allTokens,
            groupName: groupTitle.value,
            message: '채팅방이 생성되었습니다',
          );
        }
      } catch (e) {
        print('❌ FCM 그룹 생성 알림 발송 실패: $e');
      }
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
