import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'chat_message_bubble.dart';
import 'package:what_is_your_eta/data/model/message_model.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';

class ChatMessageListView extends StatelessWidget {
  final RxList<MessageModel> messages;
  final Map<String, UserModel> userMap;
  final String myUid;

  const ChatMessageListView({
    super.key,
    required this.messages,
    required this.userMap,
    required this.myUid,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final msg = messages[index];
          final sender = userMap[msg.senderId];
          final isMe = msg.senderId == myUid;

          return ChatMessageBubble(
            isMe: isMe,
            isSystem: msg.senderId == 'system',
            message: msg.text,
            senderName: sender?.name,
            senderPhotoUrl: sender?.photoUrl,
          );
        },
      ),
    );
  }
}
