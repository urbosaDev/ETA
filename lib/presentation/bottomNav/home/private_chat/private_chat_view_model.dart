import 'dart:async';

import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/private_chat_model.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/chat_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';

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
  final RxList<UserModel> friendList = <UserModel>[].obs;
  final RxList<PrivateChatModel> chatRoomList = <PrivateChatModel>[].obs;
  final RxBool isLoading = true.obs;

  StreamSubscription<UserModel>? _userSub;

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

  Future<void> _initialize() async {
    isLoading.value = true;
    final currentUser = _authRepository.getCurrentUser();
    if (currentUser != null) {
      final initialUser = await _userRepository.getUser(currentUser.uid);
      if (initialUser != null) {
        userModel.value = initialUser;
        await _refreshRelatedData(initialUser);
      }
      _startUserStream(currentUser.uid);
    }
    isLoading.value = false;
  }

  void _startUserStream(String uid) {
    _userSub = _userRepository.streamUser(uid).listen((user) async {
      userModel.value = user;
      await _refreshRelatedData(user);
    });
  }

  Future<void> _refreshRelatedData(UserModel user) async {
    await getUsersByUids(user.friendsUids);
    await getChatRoomIds(user.privateChatIds);
  }

  Future<void> getUsersByUids(List<String> uids) async {
    friendList.value = await _userRepository.getUsersByUids(uids);
  }

  Future<void> getChatRoomIds(List<String> chatRoomIds) async {
    chatRoomList.clear();
    for (final id in chatRoomIds) {
      final chatRoom = await _chatRepository.getChatRoom(id);
      if (chatRoom != null) {
        chatRoomList.add(PrivateChatModel.fromJson(chatRoom));
      }
    }
  }

  //상대 uid 추출 함수
  String getOpponentUid(String myUid, List<String> participants) {
    return participants.firstWhere((id) => id != myUid);
  }

  Future<UserModel?> getOpponentInfo(PrivateChatModel chatRoom) async {
    final myUid = userModel.value?.uid;
    if (myUid == null) return null;

    final opponentUid = getOpponentUid(myUid, chatRoom.participantIds);
    return await _userRepository.getUser(opponentUid);
  }

  Future<void> addFriend(String uniqueId) async {
    final friendUid = await _userRepository.getUidByUniqueId(uniqueId);
    if (friendUid == null) return;
    // TODO: Implement friend addition logic
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
}
