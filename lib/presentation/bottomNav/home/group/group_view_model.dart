import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/group_model.dart';
import 'package:what_is_your_eta/data/model/promise_model.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/chat_repository.dart';
import 'package:what_is_your_eta/data/repository/group_repository.dart';
import 'package:what_is_your_eta/data/repository/promise_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';

class GroupViewModel extends GetxController {
  final GroupModel group;
  final GroupRepository _groupRepository;
  final UserRepository _userRepository;
  final AuthRepository _authRepository;
  final PromiseRepository _promiseRepository;
  final ChatRepository _chatRepository;

  GroupViewModel({
    required GroupRepository groupRepository,
    required UserRepository userRepository,
    required AuthRepository authRepository,
    required PromiseRepository promiseRepository,
    required ChatRepository chatRepository,
    required this.group,
  }) : _groupRepository = groupRepository,
       _userRepository = userRepository,
       _authRepository = authRepository,
       _promiseRepository = promiseRepository,
       _chatRepository = chatRepository;

  final Rx<GroupModel?> groupModel = Rx<GroupModel?>(null);
  final RxBool isLoading = true.obs;
  StreamSubscription<GroupModel>? _groupSub;

  final RxList<UserModel> memberList = <UserModel>[].obs;
  final RxList<UserModel> selectedFriends = <UserModel>[].obs;
  final RxList<UserModel> friendList = <UserModel>[].obs;

  final Rx<String?> snackbarMessage = Rx<String?>(null);
  final RxList<PromiseModel> promiseList = <PromiseModel>[].obs;

  final RxMap<String, bool> promiseParticipationMap = <String, bool>{}.obs;
  final RxString myUid = ''.obs;
  @override
  void onInit() {
    super.onInit();
    groupModel.value = group;
    _initialize();
  }

  @override
  void onClose() {
    _groupSub?.cancel();
    debugPrint('🗑️ GroupViewModel deleted');
    super.onClose();
  }

  bool isOtherUser(UserModel user) => user.uid != myUid.value;

  Future<void> _initialize() async {
    isLoading.value = true;
    final currentUid = _authRepository.getCurrentUid();
    if (currentUid != null) {
      myUid.value = currentUid;
    }

    final fetchedGroup = await _groupRepository.getGroup(group.id);
    if (fetchedGroup == null) {
      isLoading.value = false;
      return;
    }

    groupModel.value = fetchedGroup;
    await _fetchMember(fetchedGroup.memberIds);
    await _fetchPromise(fetchedGroup);
    // ✅ 유저 가져오고 친구 리스트 받아오기
    final currentUser = _authRepository.getCurrentUser();
    if (currentUser != null) {
      await _fetchFriendList(currentUser.uid);
    }

    _startGroupStream();
    isLoading.value = false;
  }

  Future<void> _fetchFriendList(String uid) async {
    final user = await _userRepository.getUser(uid);
    if (user != null) {
      final friends = await _userRepository.getUsersByUids(user.friendsUids);
      friendList.value = friends;
    }
  }

  void _startGroupStream() {
    _groupSub = _groupRepository.streamGroup(group.id).listen((group) {
      groupModel.value = group;

      _fetchMember(group.memberIds);
      _fetchPromise(group);
    });
  }

  Future<void> _fetchMember(List<String> memberIds) async {
    final users = await _userRepository.getUsersByUids(memberIds);
    memberList.value = users;

    selectedFriends.removeWhere((f) => memberIds.contains(f.uid));
  }

  void toggleFriend(UserModel user) {
    final isExistingMember = memberList.any((u) => u.uid == user.uid);
    if (isExistingMember) return;

    if (selectedFriends.any((u) => u.uid == user.uid)) {
      selectedFriends.removeWhere((u) => u.uid == user.uid);
    } else {
      selectedFriends.add(user);
    }
  }

  Future<void> invite() async {
    final group = groupModel.value;
    if (group == null || group.id.isEmpty || selectedFriends.isEmpty) return;

    final groupId = group.id;
    final updatedMemberIds =
        {...group.memberIds, ...selectedFriends.map((u) => u.uid)}.toList();

    await _groupRepository.updateGroupMembers(groupId, updatedMemberIds);
    for (final user in selectedFriends) {
      await _userRepository.addGroupId(user.uid, groupId);
    }

    selectedFriends.clear();

    // 메시지 넣기 + 타이머로 자동 초기화
    snackbarMessage.value = '친구를 그룹에 초대했습니다.';
    Future.delayed(Duration(milliseconds: 70), () {
      snackbarMessage.value = null; // ❗ ViewModel 내부에서 직접 초기화
    });
  }

  Future<void> _fetchPromise([GroupModel? paramGroup]) async {
    final group = paramGroup ?? groupModel.value;
    if (group == null || group.promiseIds.isEmpty) {
      promiseList.clear();
      return;
    }

    final promises = await _promiseRepository.getPromisesByIds(
      group.promiseIds,
    );
    promiseList.value = promises;
    final currentUid = _authRepository.getCurrentUid();
    final Map<String, bool> newParticipationMap = {};
    for (final promise in promises) {
      newParticipationMap[promise.id] = promise.memberIds.contains(currentUid);
    }
    promiseParticipationMap.value = newParticipationMap;
  }

  final RxBool navigateToChat = false.obs;
  void resetNavigateToChat() {
    navigateToChat.value = false;
  }

  Future<String?> createChatRoom(String friendUid) async {
    try {
      final myUid = _authRepository.getCurrentUser()!.uid;
      final chatRoomId = generateChatRoomId(myUid, friendUid);

      final exists = await _chatRepository.chatRoomExists(chatRoomId);
      if (exists) {
        navigateToChat.value = true;
        return chatRoomId;
      }

      final chatRoomData = {
        'participantIds': [myUid, friendUid],
        'lastMessage': '',
        'lastMessageAt': DateTime.now(),
      };

      await _chatRepository.createChatRoom(
        chatId: chatRoomId,
        data: chatRoomData,
      );

      await _userRepository.addPrivateChatId(myUid, chatRoomId);
      await _userRepository.addPrivateChatId(friendUid, chatRoomId);
      navigateToChat.value = true;
      return chatRoomId;
    } catch (e) {
      navigateToChat.value = false;
      return null;
    }
  }

  String generateChatRoomId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }
}
