import 'dart:async';

import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/message_model.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/data/repository/chat_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';

class PrivateChatRoomViewModel extends GetxController {
  final ChatRepository _chatRepository;
  final UserRepository _userRepository;
  final String chatRoomId;
  final UserModel my;
  final String friendUid; // ❗️이제는 uid만 받기

  PrivateChatRoomViewModel({
    required ChatRepository chatRepository,
    required UserRepository userRepository,
    required this.chatRoomId,
    required this.my,
    required this.friendUid,
  }) : _chatRepository = chatRepository,
       _userRepository = userRepository;

  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final Rxn<UserModel> friendModel = Rxn<UserModel>();
  StreamSubscription<UserModel>? _friendSub;

  @override
  void onInit() {
    super.onInit();
    _listenToMessages();
    _listenToFriend();
  }

  void _listenToMessages() {
    _chatRepository.streamMessages(chatRoomId).listen((msgList) {
      messages.value = msgList;
    });
  }

  void _listenToFriend() {
    _friendSub = _userRepository
        .streamUser(friendUid)
        .listen((user) => friendModel.value = user);
  }

  @override
  void onClose() {
    _friendSub?.cancel();
    super.onClose();
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    final message = MessageModel(
      senderId: my.uid,
      text: content.trim(),
      sentAt: DateTime.now(),
      readBy: [my.uid],
    );

    await _chatRepository.sendMessage(chatRoomId, message);
  }
}
