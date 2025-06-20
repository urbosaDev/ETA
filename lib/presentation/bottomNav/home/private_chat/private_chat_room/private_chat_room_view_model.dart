import 'dart:async';

import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/message_model.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/data/repository/chat_repository.dart';
import 'package:what_is_your_eta/data/repository/fcm_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';

class PrivateChatRoomViewModel extends GetxController {
  final ChatRepository _chatRepository;
  final UserRepository _userRepository;
  final FcmRepository _fcmRepository;
  final String chatRoomId;

  final UserModel my;

  final String friendUid;

  PrivateChatRoomViewModel({
    required ChatRepository chatRepository,
    required UserRepository userRepository,
    required FcmRepository fcmRepository,
    required this.chatRoomId,
    required this.myUid,
    required this.friendUid,
  }) : _chatRepository = chatRepository,
       _userRepository = userRepository,
       _fcmRepository = fcmRepository;

  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final Rxn<UserModel> friendModel = Rxn<UserModel>();
  StreamSubscription<UserModel>? _friendSub;
  final Rxn<UserModel> myModel = Rxn<UserModel>();
  StreamSubscription<UserModel>? _mySub;

  @override
  void onInit() {
    super.onInit();
    _listenToMessages();
    _listenToMeAndFriend();
  }

  void _listenToMessages() {
    _chatRepository.streamMessages(chatRoomId).listen((msgList) {
      messages.value = msgList;
    });
  }

  void _listenToMeAndFriend() {
    _friendSub = _userRepository
        .streamUser(friendUid)
        .listen((user) => friendModel.value = user);
    _mySub = _userRepository
        .streamUser(myUid)
        .listen((user) => myModel.value = user);
  }

  @override
  void onClose() {
    _friendSub?.cancel();
    _mySub?.cancel();
    super.onClose();
    // debugPrint('🗑️ PrivateChatRoomViewModel deleted');
  }

  Future<void> sendMessage(String content) async {
    final myName = myModel.value?.name;

    if (content.trim().isEmpty || myName == null) return;

    final message = TextMessageModel(
      senderId: myUid,
      text: content.trim(),
      sentAt: DateTime.now(),
      readBy: [myUid],
    );

    await _chatRepository.sendMessage(chatRoomId, message);
    try {
      final tokens = await _userRepository.getFcmTokens(friendUid);

      if (tokens.isNotEmpty) {

        await _fcmRepository.sendChatNotification(
          targetTokens: tokens,
          senderName: my.name,
          message: content.trim(),
        );

      }
    } catch (e) {
      return;
    }
  }
}
