import 'dart:async';

import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/chat_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';

enum UserRelationStatus { unknown, normal, blocked }

class UserProfileViewModel extends GetxController {
  final String targetUserUid;
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final ChatRepository _chatRepository;
  UserProfileViewModel({
    required this.targetUserUid,
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required ChatRepository chatRepository,
  }) : _authRepository = authRepository,
       _userRepository = userRepository,
       _chatRepository = chatRepository;

  @override
  void onInit() {
    _initialize();
    super.onInit();
  }

  @override
  void onClose() {
    _userSub?.cancel();
    super.onClose();
  }

  final RxBool isLoading = false.obs;
  final RxBool isMyFriend = false.obs;
  final Rx<UserModel?> targetUserModel = Rx<UserModel?>(null);
  final Rx<UserModel?> currentUserModel = Rx<UserModel?>(null);
  final Rx<UserRelationStatus> relationStatus = UserRelationStatus.normal.obs;
  StreamSubscription<UserModel>? _userSub;
  final RxBool isRelationTransitioning = false.obs;
  final RxnString systemMessage = RxnString(null);
  get currentUserUid => _authRepository.getCurrentUser()?.uid;
  Future<void> _initialize() async {
    isLoading.value = true;

    final currentUser = _authRepository.getCurrentUser();
    if (currentUser == null) {
      isLoading.value = false;
      return;
    }

    final targetUser = await _userRepository.getUser(targetUserUid);
    targetUserModel.value = targetUser;

    _updateRelationStatus(currentUserModel.value, targetUser);

    _userSub = _userRepository.streamUser(currentUser.uid).listen((user) {
      currentUserModel.value = user;
      _updateRelationStatus(user, targetUserModel.value);
    });

    isLoading.value = false;
  }

  void _updateRelationStatus(UserModel? currentUser, UserModel? targetUser) {
    if (targetUser == null || targetUser.uniqueId == 'unknown') {
      relationStatus.value = UserRelationStatus.unknown;
    } else if (currentUser?.blockFriendsUids.contains(targetUser.uid) == true) {
      relationStatus.value = UserRelationStatus.blocked;
    } else {
      relationStatus.value = UserRelationStatus.normal;
    }

    if (currentUser != null && targetUser != null) {
      isMyFriend.value = currentUser.friendsUids.contains(targetUser.uid);
    } else {
      isMyFriend.value = false;
    }
  }

  Future<void> addFriend() async {
    final currentUser = _authRepository.getCurrentUser();
    if (currentUser == null || isMyFriend.value) return;

    isRelationTransitioning.value = true;
    try {
      await _userRepository.addFriendUid(currentUser.uid, targetUserUid);
      currentUserModel.update((user) {
        user?.friendsUids.add(targetUserUid);
      });
      _updateRelationStatus(currentUserModel.value, targetUserModel.value);
      systemMessage.value = '친구 추가에 성공했어요 🎉';
    } catch (_) {
      systemMessage.value = '친구 추가에 실패했어요 🥲';
    } finally {
      isRelationTransitioning.value = false;
    }
  }

  Future<void> deleteFriend() async {
    final currentUser = _authRepository.getCurrentUser();
    if (currentUser == null || !isMyFriend.value) return;

    isRelationTransitioning.value = true;
    try {
      await _userRepository.removeFriendUid(
        currentUid: currentUser.uid,
        friendUid: targetUserUid,
      );
      currentUserModel.update((user) {
        user?.friendsUids.remove(targetUserUid);
      });
      _updateRelationStatus(currentUserModel.value, targetUserModel.value);
      systemMessage.value = '친구가 삭제되었습니다 🎉';
    } catch (_) {
      systemMessage.value = '친구 삭제에 실패했어요 🥲';
    } finally {
      isRelationTransitioning.value = false;
    }
  }

  Future<void> blockUserId() async {
    final currentUser = _authRepository.getCurrentUser();
    if (currentUser == null) return;

    isRelationTransitioning.value = true;
    try {
      await _userRepository.addBlockFriendUid(
        currentUid: currentUser.uid,
        blockFriendUid: targetUserUid,
      );
      currentUserModel.update((user) {
        user?.blockFriendsUids.add(targetUserUid);
      });
      _updateRelationStatus(currentUserModel.value, targetUserModel.value);
      systemMessage.value = '차단에 성공했어요 🎉';
    } catch (_) {
      systemMessage.value = '차단에 실패했어요 🥲';
    } finally {
      isRelationTransitioning.value = false;
    }
  }

  Future<void> unblockUserId() async {
    final currentUser = _authRepository.getCurrentUser();
    if (currentUser == null) return;

    isRelationTransitioning.value = true;
    try {
      await _userRepository.removeBlockFriendUid(
        currentUid: currentUser.uid,
        blockFriendUid: targetUserUid,
      );
      currentUserModel.update((user) {
        user?.blockFriendsUids.remove(targetUserUid);
      });
      _updateRelationStatus(currentUserModel.value, targetUserModel.value);
      systemMessage.value = '차단 해제에 성공했어요 🎉';
    } catch (_) {
      systemMessage.value = '차단 해제에 실패했어요 🥲';
    } finally {
      isRelationTransitioning.value = false;
    }
  }

  String generateChatRoomId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  final RxnString navigateToChatRoomId = RxnString(null);
  void resetNavigateToChat() {
    navigateToChatRoomId.value = null;
  }

  final RxBool isChatRoomLoading = false.obs;
  Future<String?> createChatRoom() async {
    isChatRoomLoading.value = true;
    try {
      final myUid = _authRepository.getCurrentUser()?.uid;
      if (myUid == null) {
        isChatRoomLoading.value = false;
        return null;
      }

      final chatRoomId = generateChatRoomId(myUid, targetUserUid);

      final exists = await _chatRepository.chatRoomExists(chatRoomId);
      if (exists) {
        final room = await _chatRepository.getChatRoom(chatRoomId);
        if (room != null && !room.participantIds.contains(myUid)) {
          await _chatRepository.markUserAsJoinedInChatRoom(
            roomId: chatRoomId,
            userId: myUid,
          );
          await _userRepository.addPrivateChatId(myUid, chatRoomId);
        }
        navigateToChatRoomId.value = chatRoomId;
        isChatRoomLoading.value = false;
        return chatRoomId;
      }

      final chatRoomData = {
        'participantIds': [myUid, targetUserUid],
        'lastMessage': '',
        'lastMessageAt': DateTime.now(),
      };

      await _chatRepository.createChatRoom(
        chatId: chatRoomId,
        data: chatRoomData,
      );
      await _userRepository.addPrivateChatId(myUid, chatRoomId);
      await _userRepository.addPrivateChatId(targetUserUid, chatRoomId);
      navigateToChatRoomId.value = chatRoomId;

      return chatRoomId;
    } catch (e) {
      navigateToChatRoomId.value = null;
      return null;
    } finally {
      isChatRoomLoading.value = false;
    }
  }
}
