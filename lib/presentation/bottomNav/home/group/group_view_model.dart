import 'dart:async';

import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/group_model.dart';
import 'package:what_is_your_eta/data/model/promise_model.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/chat_repository.dart';
import 'package:what_is_your_eta/data/repository/group_repository.dart';
import 'package:what_is_your_eta/data/repository/promise_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';
import 'package:what_is_your_eta/domain/usecase/get_friends_with_status_usecase.dart';
import 'package:what_is_your_eta/presentation/models/friend_info_model.dart';

class GroupViewModel extends GetxController {
  final GroupModel group;
  final GroupRepository _groupRepository;
  final UserRepository _userRepository;
  final AuthRepository _authRepository;
  final PromiseRepository _promiseRepository;
  final ChatRepository _chatRepository;
  final GetFriendsWithStatusUsecase _getFriendsWithStatusUsecase;

  GroupViewModel({
    required GroupRepository groupRepository,
    required UserRepository userRepository,
    required AuthRepository authRepository,
    required PromiseRepository promiseRepository,
    required ChatRepository chatRepository,
    required this.group,
    required GetFriendsWithStatusUsecase getFriendsWithStatusUsecase,
    required notificationApiRepository,
  }) : _groupRepository = groupRepository,
       _userRepository = userRepository,
       _authRepository = authRepository,
       _promiseRepository = promiseRepository,
       _chatRepository = chatRepository,
       _getFriendsWithStatusUsecase = getFriendsWithStatusUsecase;

  final Rx<GroupModel?> groupModel = Rx<GroupModel?>(null);
  final RxBool isLoading = true.obs;
  StreamSubscription<GroupModel>? _groupSub;
  StreamSubscription<UserModel>? _userSub;
  final Rx<UserModel?> userModel = Rx<UserModel?>(null);
  final RxList<FriendInfoModel> memberList = <FriendInfoModel>[].obs;
  final RxList<FriendInfoModel> selectedFriends = <FriendInfoModel>[].obs;
  final RxList<FriendInfoModel> friendList = <FriendInfoModel>[].obs;

  final Rx<String?> snackbarMessage = Rx<String?>(null);
  final Rx<PromiseModel?> currentPromise = Rx<PromiseModel?>(null);
  final Rx<UserModel?> leaderModel = Rx<UserModel?>(null);
  final RxBool isParticipating = false.obs;
  String? get currentUser => _authRepository.getCurrentUser()?.uid;

  bool get isMyGroup => groupModel.value?.createrId == currentUser;
  bool isOtherUser(UserModel user) => user.uid != currentUser;
  final RxBool isPromiseExisted = false.obs;
  List<FriendInfoModel> get validFriends =>
      friendList
          .where((friendInfo) => friendInfo.status == UserStatus.active)
          .toList();
  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  @override
  void onClose() {
    _groupSub?.cancel();
    _userSub?.cancel();
    super.onClose();
  }

  Future<void> _initialize() async {
    isLoading.value = true;

    final fetchedGroup = await _groupRepository.getGroup(group.id);
    if (fetchedGroup?.currentPromiseId != null) {
      isPromiseExisted.value = true;
    }
    if (fetchedGroup == null) {
      isLoading.value = false;
      return;
    }

    groupModel.value = fetchedGroup;

    await _fetchPromise(fetchedGroup);
    await fetchLeaderInfo(fetchedGroup.createrId);
    final currentUser = _authRepository.getCurrentUser();
    if (currentUser != null) {
      final user = await _userRepository.getUser(currentUser.uid);
      if (user != null) {
        userModel.value = user;
        await getUsersByUids(user);
        await _fetchMember();
      }
    }

    _userSub = _userRepository.streamUser(currentUser?.uid ?? '').listen((
      user,
    ) {
      userModel.value = user;
      getUsersByUids(user);
      final latestGroup = groupModel.value;
      if (latestGroup != null) {
        _fetchMember();
      }
    });

    _startGroupStream();
    isLoading.value = false;
  }

  Future<void> fetchLeaderInfo(String uid) async {
    final user = await _userRepository.getUser(uid);
    leaderModel.value = user;
  }

  Future<void> getUsersByUids(UserModel user) async {
    final myFriendsUids = userModel.value?.friendsUids;
    if (myFriendsUids == null || myFriendsUids.isEmpty) {
      friendList.clear();
      return;
    }

    friendList.value = await _getFriendsWithStatusUsecase.assignStatusToUsers(
      uids: myFriendsUids,
    );
  }

  void _startGroupStream() {
    _groupSub = _groupRepository.streamGroup(group.id).listen((group) {
      groupModel.value = group;
      isPromiseExisted.value = group.currentPromiseId != null;
      _fetchMember();
      _fetchPromise(group);
      if (leaderModel.value?.uid != group.createrId) {
        fetchLeaderInfo(group.createrId);
      }
    });
  }

  Future<void> _fetchMember() async {
    final memberUids = groupModel.value?.memberIds;
    if (memberUids == null || memberUids.isEmpty) {
      memberList.clear();
      return;
    }
    // UseCase를 사용하여 상태가 반영된 멤버 목록을 가져옴
    memberList.value = await _getFriendsWithStatusUsecase.assignStatusToUsers(
      uids: memberUids,
    );
  }

  void toggleFriend(FriendInfoModel friend) {
    final isExistingMember = memberList.any(
      (f) => f.userModel.uid == friend.userModel.uid,
    );
    if (isExistingMember) return;

    if (selectedFriends.any((f) => f.userModel.uid == friend.userModel.uid)) {
      selectedFriends.removeWhere(
        (f) => f.userModel.uid == friend.userModel.uid,
      );
    } else {
      selectedFriends.add(friend);
    }
  }

  Future<void> invite() async {
    final group = groupModel.value;
    if (group == null || group.id.isEmpty || selectedFriends.isEmpty) return;

    final groupId = group.id;
    final updatedMemberIds =
        {
          ...group.memberIds,
          ...selectedFriends.map((f) => f.userModel.uid),
        }.toList();

    await _groupRepository.updateGroupMembers(groupId, updatedMemberIds);
    for (final friend in selectedFriends) {
      await _userRepository.addGroupId(friend.userModel.uid, groupId);
    }

    selectedFriends.clear();

    snackbarMessage.value = '친구를 그룹에 초대했습니다.';
    Future.delayed(Duration(milliseconds: 70), () {
      snackbarMessage.value = null;
    });
  }

  Future<void> _fetchPromise([GroupModel? paramGroup]) async {
    final group = paramGroup ?? groupModel.value;
    final currentPromiseId = group?.currentPromiseId;
    if (group == null || currentPromiseId == null) {
      currentPromise.value = null;
      isParticipating.value = false;
      return;
    }

    final promise = await _promiseRepository.getPromise(currentPromiseId);
    if (promise == null) {
      currentPromise.value = null;
      return;
    }

    currentPromise.value = promise;

    final currentUid = _authRepository.getCurrentUid();
    isParticipating.value = promise.memberIds.contains(currentUid);
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

  Future<void> leaveGroup() async {
    final uid = _authRepository.getCurrentUid();
    if (uid == null || isMyGroup) return;

    try {
      isLoading.value = true;

      final group = groupModel.value;
      if (group == null) return;

      await _groupRepository.removeUserFromGroup(
        groupId: group.id,
        userId: uid,
      );

      await _userRepository.removeGroupId(userId: uid, groupId: group.id);

      final currentId = group.currentPromiseId;
      if (currentId != null) {
        await _promiseRepository.removeUserFromPromise(
          promiseId: currentId,
          userId: uid,
        );
      }

      final remainingMembers =
          group.memberIds.where((id) => id != uid).toList();

      if (remainingMembers.isEmpty) {
        final currentId = group.currentPromiseId;
        if (currentId != null) {
          await _promiseRepository.deletePromise(currentId);
        }
        await _groupRepository.deleteGroup(group.id);
      }
      isDeleteAndLeaveGroup.value = true;
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }

  final RxBool isDeleteAndLeaveGroup = false.obs;

  Future<void> deleteGroup() async {
    if (!isMyGroup) return;
    final group = groupModel.value;
    if (group == null) return;

    try {
      isLoading.value = true;

      final currentId = group.currentPromiseId;
      if (currentId != null) {
        await _promiseRepository.deletePromise(currentId);
      }

      for (final memberId in group.memberIds) {
        await _userRepository.removeGroupId(
          userId: memberId,
          groupId: group.id,
        );
      }

      await _groupRepository.deleteGroup(group.id);
      isDeleteAndLeaveGroup.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  final RxBool successEndPromise = false.obs;

  Future<void> endPromise() async {
    final group = groupModel.value;
    final promiseId = group?.currentPromiseId;
    if (group == null || promiseId == null) return;

    final promise = await _promiseRepository.getPromise(promiseId);
    if (promise == null) return;

    if (promise.notifyStartScheduled == false) {
      await _promiseRepository.deletePromise(promiseId);

      await _groupRepository.clearCurrentPromiseId(group.id);
    } else {
      await _groupRepository.endCurrentPromise(
        groupId: group.id,
        promiseId: promiseId,
      );
    }

    currentPromise.value = null;
    isPromiseExisted.value = false;
    successEndPromise.value = true;
  }

  Future<void> changeLeader({required String leaderUid}) async {
    final group = groupModel.value;
    if (group == null || group.id.isEmpty) return;

    try {
      isLoading.value = true;

      await _groupRepository.forceUpdateGroupLeader(
        groupId: group.id,
        uid: leaderUid,
      );
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeFriend({required String friendUid}) async {
    final currentUser = _authRepository.getCurrentUser();
    if (currentUser == null) return;

    try {
      await _userRepository.removeFriendUid(
        currentUid: currentUser.uid,
        friendUid: friendUid,
      );
    } catch (e) {
      return;
    }
  }

  Future<void> blockUserId({required String friendUid}) async {
    final currentUser = _authRepository.getCurrentUser();
    if (currentUser == null) return;

    try {
      await _userRepository.addBlockFriendUid(
        currentUid: currentUser.uid,
        blockFriendUid: friendUid,
      );
    } catch (e) {
      return;
    }
  }

  Future<void> unblockUserId({required String friendUid}) async {
    final currentUser = _authRepository.getCurrentUser();
    if (currentUser == null) return;
    try {
      await _userRepository.removeBlockFriendUid(
        currentUid: currentUser.uid,
        blockFriendUid: friendUid,
      );
    } catch (e) {
      return;
    }
  }
}
