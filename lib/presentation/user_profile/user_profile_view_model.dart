import 'dart:async';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/chat_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';

import 'package:what_is_your_eta/domain/usecase/get_single_with_status_usecase.dart';
import 'package:what_is_your_eta/presentation/models/friend_info_model.dart';

class UserProfileViewModel extends GetxController {
  final String targetUserUid;
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final ChatRepository _chatRepository;
  final GetSingleUserWithStatusUsecase _getSingleUserUsecase;

  UserProfileViewModel({
    required this.targetUserUid,
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required ChatRepository chatRepository,
    required GetSingleUserWithStatusUsecase getSingleUserWithStatusUsecase,
  }) : _authRepository = authRepository,
       _userRepository = userRepository,
       _chatRepository = chatRepository,
       _getSingleUserUsecase = getSingleUserWithStatusUsecase;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  @override
  void onClose() {
    _userSub?.cancel();
    super.onClose();
  }

  StreamSubscription<UserModel?>? _userSub;

  final RxBool isLoading = true.obs;

  final Rx<FriendInfoModel?> friendInfo = Rx<FriendInfoModel?>(null);

  final RxBool isMyFriend = false.obs;

  final RxBool isRelationTransitioning = false.obs;
  final RxnString systemMessage = RxnString(null);

  String get currentUserUid => _authRepository.getCurrentUser()!.uid;

  Future<void> _initialize() async {
    await refetchTargetUserProfile();
    _startUserStream(currentUserUid);
  }

  void _startUserStream(String uid) {
    _userSub = _userRepository.streamUser(uid).listen((myUserModel) {
      isMyFriend.value = myUserModel.friendsUids.contains(targetUserUid);
      refetchTargetUserProfile();
    });
  }

  Future<void> refetchTargetUserProfile() async {
    isLoading.value = true;
    try {
      friendInfo.value = await _getSingleUserUsecase.getSingleUserWithStatus(
        targetUserUid,
      );
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _performRelationAction(
    Future<void> Function() action,
    String successMessage,
  ) async {
    if (isRelationTransitioning.value) return;
    isRelationTransitioning.value = true;
    try {
      await action();
      systemMessage.value = successMessage;
    } catch (e) {
      systemMessage.value = '작업에 실패했어요 🥲: $e';
    } finally {
      isRelationTransitioning.value = false;
    }
  }

  Future<void> addFriend() => _performRelationAction(
    () => _userRepository.addFriendUid(currentUserUid, targetUserUid),
    '친구 추가에 성공했어요 🎉',
  );
  Future<void> deleteFriend() => _performRelationAction(
    () => _userRepository.removeFriendUid(
      currentUid: currentUserUid,
      friendUid: targetUserUid,
    ),
    '친구가 삭제되었습니다.',
  );
  Future<void> blockUserId() => _performRelationAction(
    () => _userRepository.addBlockFriendUid(
      currentUid: currentUserUid,
      blockFriendUid: targetUserUid,
    ),
    '차단에 성공했어요.',
  );
  Future<void> unblockUserId() => _performRelationAction(
    () => _userRepository.removeBlockFriendUid(
      currentUid: currentUserUid,
      blockFriendUid: targetUserUid,
    ),
    '차단 해제에 성공했어요.',
  );

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
        await _chatRepository.getChatRoom(chatRoomId);
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
