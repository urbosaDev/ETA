import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/message_model.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/data/repository/chat_repository.dart';

class PrivateChatRoomViewModel extends GetxController {
  final ChatRepository _chatRepository;
  final String chatRoomId;
  final UserModel my;
  final UserModel friend;

  PrivateChatRoomViewModel({
    required ChatRepository chatRepository,
    required this.chatRoomId,
    required this.my,
    required this.friend,
  }) : _chatRepository = chatRepository;

  final RxList<MessageModel> messages = <MessageModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _listenToMessages();
  }

  void _listenToMessages() {
    _chatRepository.streamMessages(chatRoomId).listen((msgList) {
      messages.value = msgList;
    });
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
