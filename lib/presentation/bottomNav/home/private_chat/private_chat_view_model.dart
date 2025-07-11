import 'dart:async';

import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/chat_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';

import 'package:what_is_your_eta/presentation/models/chat_room_display_model.dart';
import 'package:what_is_your_eta/presentation/models/friend_info_model.dart';

class PrivateChatViewModel extends GetxController {
  final UserRepository _userRepository;
  final AuthRepository _authRepository;
  final ChatRepository _chatRepository;

  PrivateChatViewModel({
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required ChatRepository chatRepository,
  }) : _authRepository = authRepository,
       _userRepository = userRepository,
       _chatRepository = chatRepository;

  final Rx<UserModel?> userModel = Rx<UserModel?>(null);
  final RxList<FriendInfoModel> friendList = <FriendInfoModel>[].obs;
  final RxList<String> blockedUidsList = <String>[].obs;
  final RxList<ChatRoomDisplayModel> chatRoomList =
      <ChatRoomDisplayModel>[].obs;
  final RxBool isLoading = true.obs;

  StreamSubscription<UserModel>? _userSub;
  final RxBool navigateToChat = false.obs;

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

  Future<void> _initialize() async {
    isLoading.value = true;
    final currentUser = _authRepository.getCurrentUser();
    if (currentUser == null) {
      isLoading.value = false;
      return;
    }
    _startUserStream(currentUser.uid);
    isLoading.value = false;
  }

  void _startUserStream(String uid) {
    _userSub = _userRepository.streamUser(uid).listen((user) async {
      userModel.value = user;
      blockedUidsList.value = List<String>.from(user.blockFriendsUids ?? []);
      await getUsersByUids(user);
      await getChatRoomIds(user);
    });
  }

  Future<void> getUsersByUids(UserModel user) async {
    final currentUserData = user;
    if (currentUserData == null) return;
    final uids = List<String>.from(currentUserData.friendsUids ?? []);
    final users = await _userRepository.getUsersByUids(uids);
    friendList.value =
        users.map((friend) {
          final isBlocked = blockedUidsList.contains(friend.uid);
          return FriendInfoModel(userModel: friend, isBlocked: isBlocked);
        }).toList();
  }

  Future<void> getChatRoomIds(UserModel user) async {
    final currentUserData = user;
    if (currentUserData == null) {
      chatRoomList.assignAll([]);
      return;
    }

    final myUid = currentUserData.uid;
    final blockedUids = List<String>.from(
      currentUserData.blockFriendsUids ?? [],
    );
    final userChatRoomIds = List<String>.from(
      currentUserData.privateChatIds ?? [],
    );

    if (userChatRoomIds.isEmpty) {
      chatRoomList.assignAll([]);
      return;
    }

    final opponentUids =
        userChatRoomIds
            .map((id) {
              final parts = id.split('_');
              if (parts.length != 2) return null;
              return (parts[0] == myUid) ? parts[1] : parts[0];
            })
            .whereType<String>()
            .toSet()
            .toList();

    final List<UserModel> fetchedOpponentUsers = await _userRepository
        .getUsersByUids(opponentUids);

    final List<ChatRoomDisplayModel> finalChatRoomDisplayList = [];

    for (final opponentUser in fetchedOpponentUsers) {
      if (blockedUids.contains(opponentUser.uid)) {
        continue;
      }

      final chatRoomId = generateChatRoomId(myUid, opponentUser.uid);

      finalChatRoomDisplayList.add(
        ChatRoomDisplayModel(
          chatRoomId: chatRoomId,
          opponentUser: opponentUser,
        ),
      );
    }

    chatRoomList.assignAll(finalChatRoomDisplayList);
  }

  String generateChatRoomId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  void resetNavigateToChat() {
    navigateToChat.value = false;
  }

  Future<String?> createChatRoom(String friendUid) async {
    try {
      final myUid = userModel.value!.uid;
      final chatRoomId = generateChatRoomId(myUid, friendUid);
      final exists = await _chatRepository.chatRoomExists(chatRoomId);
      if (exists) {
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

  Future<void> deleteChatRoom(String chatRoomId, String opponentUid) async {
    isLoading.value = true;
    await _userRepository.removePrivateChatId(
      uid: userModel.value!.uid,
      chatRoomId: chatRoomId,
    );
    await _userRepository.removePrivateChatId(
      uid: opponentUid,
      chatRoomId: chatRoomId,
    );

    await _chatRepository.deleteChatRoom(chatRoomId);
    isLoading.value = false;
  }

  Future<void> forceRefreshChatRooms() async {
    isLoading.value = true;
    try {
      final latestUser = await _userRepository.getUser(
        _authRepository.getCurrentUser()!.uid,
      );

      if (latestUser != null) {
        userModel.value = latestUser;
        await getUsersByUids(latestUser);
        await getChatRoomIds(latestUser);
      }
    } catch (e) {
    } finally {
      // 4. 성공하든 실패하든 로딩 상태를 해제합니다.
      isLoading.value = false;
    }
  }
}
