import 'dart:async';

import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/notification_message_model.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/chat_repository.dart';
import 'package:what_is_your_eta/data/repository/group_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';

class ProfileViewModel extends GetxController {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final ChatRepository _chatRepository;
  final GroupRepository _groupRepository;

  ProfileViewModel({
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required ChatRepository chatRepository,
    required GroupRepository groupRepository,
  }) : _authRepository = authRepository,
       _userRepository = userRepository,
       _chatRepository = chatRepository,
       _groupRepository = groupRepository;

  final Rx<UserModel?> userModel = Rx<UserModel?>(null);
  final RxList<UserModel> friendList = <UserModel>[].obs;
  final RxBool isLoading = true.obs;
  StreamSubscription<UserModel>? _userSub;

  final RxList<NotificationMessageModel> unreadMessages =
      <NotificationMessageModel>[].obs;
  StreamSubscription<List<NotificationMessageModel>>? _messageSub;
  @override
  void onInit() {
    super.onInit();
    _initialize();
    // Initialize any necessary data or state here
  }

  @override
  void onClose() {
    // Clean up resources or subscriptions if needed
    _userSub?.cancel();
    _messageSub?.cancel();
    super.onClose();
  }

  Future<void> _initialize() async {
    isLoading.value = true;
    final currentUser = _authRepository.getCurrentUser();
    if (currentUser != null) {
      final initialUser = await _userRepository.getUser(currentUser.uid);
      if (initialUser != null) {
        userModel.value = initialUser;
      }
      _startUserStream(currentUser.uid);
    }
    isLoading.value = false;
  }

  void _startUserStream(String uid) {
    _userSub = _userRepository.streamUser(uid).listen((user) async {
      userModel.value = user;
      await getUsersByUids(user.friendsUids);
    });
    _messageSub = _userRepository.streamNotificationMessages(uid).listen((
      messages,
    ) {
      unreadMessages.assignAll(messages); // RxList 업데이트
    });
  }

  Future<void> markMessageAsRead(String messageId) async {
    final uid = userModel.value?.uid;
    if (uid != null) {
      await _userRepository.markMessageAsRead(uid: uid, messageId: messageId);
    }
  }

  Future<void> getUsersByUids(List<String> uids) async {
    friendList.value = await _userRepository.getUsersByUids(uids);
  }

  String generateChatRoomId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  final RxBool navigateToChat = false.obs;
  void resetNavigateToChat() {
    navigateToChat.value = false;
  }

  Future<String?> createChatRoom(String friendUid) async {
    try {
      final myUid = userModel.value!.uid;
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

  Future<void> deleteMessage(String messageId) async {
    final uid = userModel.value?.uid;
    if (uid != null) {
      await _userRepository.deleteMessageFromUser(
        uid: uid,
        messageId: messageId,
      );
    }
  }

  final RxnString errorMessage = RxnString(null); // 메시지용
  final RxBool canEnterGroup = false.obs; // 이동 가능 여부
  final RxBool isNavigating = false.obs;
  Future<void> checkGroupNavigation(String groupId) async {
    isNavigating.value = true;
    final uid = userModel.value?.uid;
    if (uid == null) {
      canEnterGroup.value = false;
      isNavigating.value = false;
      return;
    }

    final exists = await _groupRepository.existsGroup(groupId);
    if (!exists) {
      errorMessage.value = '존재하지 않는 그룹입니다.';
      canEnterGroup.value = false;
      isNavigating.value = false;
      return;
    }

    final has = await _userRepository.userHasGroup(uid: uid, groupId: groupId);
    if (!has) {
      errorMessage.value = '속해있지 않은 그룹입니다.';
      canEnterGroup.value = false;
      isNavigating.value = false;
      return;
    }
    await Future.delayed(const Duration(milliseconds: 500));
    errorMessage.value = null;
    canEnterGroup.value = true;
    isNavigating.value = false;
  }
}
// userModel fetch, stream 
// 친구들도 fetch 
