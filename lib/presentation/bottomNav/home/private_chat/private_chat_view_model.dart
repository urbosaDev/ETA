import 'dart:async';

import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/private_chat_model.dart';
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
  // final LeaveDeleteChatUsecase _leaveDeleteChatUsecase;

  PrivateChatViewModel({
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required ChatRepository chatRepository,
  }) : _authRepository = authRepository,
       _userRepository = userRepository,
       _chatRepository = chatRepository;

  final Rx<UserModel?> userModel = Rx<UserModel?>(null);
  final RxList<FriendInfoModel> friendList = <FriendInfoModel>[].obs;
  final RxList<String> defaultFriendList = <String>[].obs;
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

  // 필요한 데이터 ,
  // 차단 정보, 내가가진 채팅방 정보, 친구정보
  // 우선 차단된 유저를 관리
  void _startUserStream(String uid) {
    _userSub = _userRepository.streamUser(uid).listen((user) async {
      userModel.value = user;

      blockedUidsList.value = user.blockFriendsUids;
      defaultFriendList.value = user.friendsUids;
      await getUsersByUids(user);
      await getChatRoomIds(user);
    });
  }

  Future<void> getUsersByUids(user) async {
    final currentUserData = user;
    if (currentUserData == null) return;
    final uids = currentUserData.friendsUids;
    final blockedUids = blockedUidsList;
    final users = await _userRepository.getUsersByUids(uids);

    friendList.value =
        users.map((user) {
          final isBlocked = blockedUids.contains(user.uid);
          return FriendInfoModel(userModel: user, isBlocked: isBlocked);
        }).toList();
  }

  Future<void> getChatRoomIds(user) async {
    chatRoomList.clear();
    final currentUserData = user;
    if (currentUserData == null) {
      chatRoomList.assignAll([]);
      return;
    }

    final myUid = currentUserData.uid;
    final blockedUids = currentUserData.blockFriendsUids;
    final userChatRoomIds = currentUserData.privateChatIds;

    final List<String> chatRoomIdsToFetch = [];
    final Map<String, String> chatRoomIdToOpponentUidMap = {};

    for (final id in userChatRoomIds) {
      final parts = id.split('_');
      if (parts.length != 2) {
        continue;
      }
      final uid1 = parts[0];
      final uid2 = parts[1];
      final opponentUid = (uid1 == myUid) ? uid2 : uid1;

      if (!blockedUids.contains(opponentUid)) {
        chatRoomIdsToFetch.add(id);
        chatRoomIdToOpponentUidMap[id] = opponentUid;
      } else {}
    }

    final List<PrivateChatModel>? fetchedChatRooms = await _chatRepository
        .getChatRoomIds(chatRoomIdsToFetch);

    final List<String> opponentUidsToFetch =
        chatRoomIdToOpponentUidMap.values.whereType<String>().toSet().toList();

    final List<UserModel> fetchedOpponentUsers = await _userRepository
        .getUsersByUids(opponentUidsToFetch);
    final Map<String, UserModel> opponentUserMap = {
      for (var user in fetchedOpponentUsers) user.uid: user,
    };

    final List<ChatRoomDisplayModel> finalChatRoomDisplayList = [];
    if (fetchedChatRooms != null) {
      for (final chatRoom in fetchedChatRooms) {
        final opponentUid = chatRoomIdToOpponentUidMap[chatRoom.id];
        final UserModel? opponent =
            opponentUid != null ? opponentUserMap[opponentUid] : null;

        if (opponent != null) {
          finalChatRoomDisplayList.add(
            ChatRoomDisplayModel(chatRoom: chatRoom, opponentUser: opponent),
          );
        } else {}
      }
    }
    chatRoomList.value = finalChatRoomDisplayList;
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
        await _chatRepository.getChatRoom(chatRoomId);
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

  // Future<void> leaveChatRoom(String chatRoomId) async {
  //   isLoading.value = true;
  //   try {
  //     await _leaveDeleteChatUsecase.leaveAndDelete(chatRoomId);
  //     // userModel.update((user) {
  //     //   user?.privateChatIds.remove(chatRoomId);
  //     // });
  //     await getChatRoomIds(userModel.value);
  //   } catch (_) {
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  Future<void> deleteChatRoom(String chatRoomId, String opponentUid) async {
    isLoading.value = true;
    await _userRepository.removePrivateChatId(
      uid: userModel.value!.uid,
      chatRoomId: chatRoomId,
    );
    await _chatRepository.deleteChatRoom(chatRoomId);
    userModel.update((user) {
      user?.privateChatIds.remove(chatRoomId);
    });

    await _userRepository.removePrivateChatId(
      uid: opponentUid,
      chatRoomId: chatRoomId,
    );

    isLoading.value = false;
  }
}
