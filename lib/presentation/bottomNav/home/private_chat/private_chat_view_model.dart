import 'dart:async';

import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/chat_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';
import 'package:what_is_your_eta/domain/usecase/get_friends_with_status_usecase.dart';

import 'package:what_is_your_eta/presentation/models/chat_room_display_model.dart';
import 'package:what_is_your_eta/presentation/models/friend_info_model.dart';

class PrivateChatViewModel extends GetxController {
  final UserRepository _userRepository;
  final AuthRepository _authRepository;
  final ChatRepository _chatRepository;
  final GetFriendsWithStatusUsecase _getFriendsWithStatusUsecase;

  PrivateChatViewModel({
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required ChatRepository chatRepository,
    required GetFriendsWithStatusUsecase getFriendsWithStatusUsecase,
  }) : _authRepository = authRepository,
       _userRepository = userRepository,
       _chatRepository = chatRepository,
       _getFriendsWithStatusUsecase = getFriendsWithStatusUsecase;

  final Rx<UserModel?> userModel = Rx<UserModel?>(null);
  StreamSubscription<UserModel>? _userSub;
  final RxList<FriendInfoModel> friendList = <FriendInfoModel>[].obs;
  final RxList<ChatRoomDisplayModel> chatRoomList =
      <ChatRoomDisplayModel>[].obs;

  final RxBool isLoading = true.obs;

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
      forceRefreshChatRooms();
      // await _updateAllLists(user);
    });
  }

  Future<void> _updateAllLists(UserModel user) async {
    userModel.value = user;

    final friendUids = user.friendsUids;

    final processedFriendList = await _getFriendsWithStatusUsecase
        .getFriendWithStatus(uids: friendUids);
    friendList.value = processedFriendList;

    await getChatRoomIds(chatIds: user.privateChatIds, myUid: user.uid);
  }

  Future<void> getChatRoomIds({
    required List<String> chatIds,
    required String myUid,
  }) async {
    if (chatIds.isEmpty) {
      chatRoomList.clear();
      return;
    }

    final opponentUids =
        chatIds
            .map((id) {
              final parts = id.split('_');
              return (parts.length == 2 && parts[0] == myUid)
                  ? parts[1]
                  : (parts.length == 2 ? parts[0] : null);
            })
            .whereType<String>()
            .toSet()
            .toList();

    if (opponentUids.isEmpty) {
      chatRoomList.clear();
      return;
    }

    final List<FriendInfoModel> processedOpponentList =
        await _getFriendsWithStatusUsecase.getFriendWithStatus(
          uids: opponentUids,
        );

    final finalChatRoomDisplayList =
        processedOpponentList
            .where((info) => info.status == UserStatus.active)
            .map((info) {
              final opponentUser = info.userModel;
              final chatRoomId = generateChatRoomId(myUid, opponentUser.uid);
              return ChatRoomDisplayModel(
                chatRoomId: chatRoomId,
                opponentUser: opponentUser,
              );
            })
            .toList();

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
        await _updateAllLists(latestUser);
      }
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }
}
