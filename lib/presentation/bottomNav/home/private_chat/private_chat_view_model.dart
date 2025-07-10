import 'dart:async';

import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/private_chat_model.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/chat_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';
import 'package:what_is_your_eta/domain/usecase/leave_delete_chat_usecase.dart';
import 'package:what_is_your_eta/presentation/models/chat_room_display_model.dart';
import 'package:what_is_your_eta/presentation/models/friend_info_model.dart';

class PrivateChatViewModel extends GetxController {
  final UserRepository _userRepository;
  final AuthRepository _authRepository;
  final ChatRepository _chatRepository;
  final LeaveDeleteChatUsecase _leaveDeleteChatUsecase;

  PrivateChatViewModel({
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required ChatRepository chatRepository,
    required LeaveDeleteChatUsecase leaveDeleteChatUsecase,
  }) : _authRepository = authRepository,
       _userRepository = userRepository,
       _chatRepository = chatRepository,
       _leaveDeleteChatUsecase = leaveDeleteChatUsecase;

  final Rx<UserModel?> userModel = Rx<UserModel?>(null);
  final RxList<FriendInfoModel> friendList = <FriendInfoModel>[].obs;
  final RxList<String> blockedUidsList = <String>[].obs;
  final RxList<ChatRoomDisplayModel> chatRoomList =
      <ChatRoomDisplayModel>[].obs;
  final RxBool isLoading = true.obs;

  StreamSubscription<UserModel>? _userSub;

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

    _userSub = _userRepository.streamUser(currentUser.uid).listen((user) async {
      userModel.value = user;
      blockedUidsList.value = user.blockFriendsUids;
      await getUsersByUids(user);
      await getChatRoomIds(user);
    });

    isLoading.value = false;
  }

  // void _startUserStream(String uid) {}

  Future<void> getUsersByUids(user) async {
    print('getUsersByUids 실행됨!');
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
    print('다시다시다시실행임!');
    // List<String> userChatRoomIds

    final currentUserData = user;
    if (currentUserData == null) {
      chatRoomList.assignAll([]);
      return;
    }

    final myUid = currentUserData.uid;
    final blockedUids = currentUserData.blockFriendsUids;
    final userChatRoomIds = currentUserData.privateChatIds;

    final List<String> chatRoomIdsToFetch = []; // Firestore에서 조회할 ID 목록
    final Map<String, String> chatRoomIdToOpponentUidMap =
        {}; // 채팅방 ID -> 상대방 UID 맵

    for (final id in userChatRoomIds) {
      final parts = id.split('_');
      if (parts.length != 2) {
        print(
          'WARNING: PrivateChatViewModel.getChatRoomIds: Invalid chat room ID format: $id',
        );
        continue;
      }
      final uid1 = parts[0];
      final uid2 = parts[1];
      final opponentUid = (uid1 == myUid) ? uid2 : uid1;

      // 오직 blockedUids에 포함되지 않은 상대방의 채팅방만 조회 대상으로 삼습니다.
      if (!blockedUids.contains(opponentUid)) {
        chatRoomIdsToFetch.add(id);
        chatRoomIdToOpponentUidMap[id] = opponentUid; // 맵에 저장
      } else {
        print(
          'DEBUG: PrivateChatViewModel.getChatRoomIds: Skipping chat room $id (Opponent $opponentUid is blocked).',
        );
      }
    }
    print(
      'DEBUG: PrivateChatViewModel.getChatRoomIds: Chat room IDs to fetch: $chatRoomIdsToFetch',
    );

    // 2. ChatRepository에서 PrivateChatModel 리스트를 병렬로 가져옵니다.
    final List<PrivateChatModel>? fetchedChatRooms = await _chatRepository
        .getChatRoomIds(chatRoomIdsToFetch);
    print(
      'DEBUG: PrivateChatViewModel.getChatRoomIds: Fetched raw chat rooms from repo: ${fetchedChatRooms?.length ?? 0} rooms.',
    );

    // 3. 모든 상대방 UserModel을 한 번에 병렬적으로 가져옵니다.
    // 필요한 상대방 UID 목록은 chatRoomIdToOpponentUidMap의 값들입니다.
    final List<String> opponentUidsToFetch =
        chatRoomIdToOpponentUidMap.values
            .whereType<String>() // 혹시 모를 null 방지
            .toSet() // 중복 제거
            .toList();
    print(
      'DEBUG: PrivateChatViewModel.getChatRoomIds: Opponent UIDs to fetch: $opponentUidsToFetch',
    );

    final List<UserModel> fetchedOpponentUsers = await _userRepository
        .getUsersByUids(opponentUidsToFetch);
    final Map<String, UserModel> opponentUserMap = {
      for (var user in fetchedOpponentUsers) user.uid: user,
    };
    print(
      'DEBUG: PrivateChatViewModel.getChatRoomIds: Fetched opponent users count: ${opponentUserMap.keys.length}',
    );

    // 4. ChatRoomDisplayModel 리스트 최종 구성
    final List<ChatRoomDisplayModel> finalChatRoomDisplayList = [];
    if (fetchedChatRooms != null) {
      for (final chatRoom in fetchedChatRooms) {
        final opponentUid =
            chatRoomIdToOpponentUidMap[chatRoom.id]; // 맵에서 상대방 UID 가져오기
        final UserModel? opponent =
            opponentUid != null ? opponentUserMap[opponentUid] : null;

        // 상대방 UserModel이 실제로 존재하는 경우에만 최종 목록에 추가합니다.
        // 이는 상대방이 탈퇴하여 UserModel 문서가 없어진 경우를 처리합니다.
        if (opponent != null) {
          finalChatRoomDisplayList.add(
            ChatRoomDisplayModel(chatRoom: chatRoom, opponentUser: opponent),
          );
        } else {
          // 상대방 정보가 없거나 유효하지 않은 채팅방은 경고를 남기고 최종 목록에서 제외합니다.
          // 이는 상대방 계정이 Firestore에서 삭제되었지만 userModel.privateChatIds에 남아있는 경우에 발생합니다.
          print(
            'WARNING: PrivateChatViewModel.getChatRoomIds: Opponent user data missing for chat room ${chatRoom.id}. Skipping.',
          );
        }
      }
    }
    chatRoomList.value = finalChatRoomDisplayList;

    print(
      'DEBUG: PrivateChatViewModel.getChatRoomIds: Final chatRoomList length: ${chatRoomList.length}',
    );

    // chatRoomList.sort(
    //   (a, b) => (b.chatRoom.lastMessageAt ?? DateTime(0)).compareTo(
    //     a.chatRoom.lastMessageAt ?? DateTime(0),
    //   ),
    // );
    print('DEBUG: PrivateChatViewModel.getChatRoomIds completed.');
  }

  Future<void> addFriend(String uniqueId) async {
    final friendUid = await _userRepository.getUidByUniqueId(uniqueId);
    if (friendUid == null) return;
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
        final room = await _chatRepository.getChatRoom(chatRoomId);

        if (room != null && !room.participantIds.contains(myUid)) {
          await _chatRepository.markUserAsJoinedInChatRoom(
            roomId: chatRoomId,
            userId: myUid,
          );
          await _userRepository.addPrivateChatId(myUid, chatRoomId);
        }
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

  Future<void> leaveChatRoom(String chatRoomId) async {
    isLoading.value = true;
    try {
      await _leaveDeleteChatUsecase.leaveAndDelete(chatRoomId);
      userModel.update((user) {
        user?.privateChatIds.remove(chatRoomId);
      });
      await getChatRoomIds(userModel.value);
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }
}
