import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:what_is_your_eta/presentation/bottomNav/%08home/private_chat/private_chat_room/private_chat_room_view_model.dart';

class PrivateChatRoomView extends GetView<PrivateChatRoomViewModel> {
  const PrivateChatRoomView({super.key});

  @override
  Widget build(BuildContext context) {
    final messageController = TextEditingController();
    final String chatRoomId = Get.arguments as String;
    final controller = Get.find<PrivateChatRoomViewModel>(tag: chatRoomId);
    final my = controller.my;
    final friend = controller.friend;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(backgroundImage: NetworkImage(friend.photoUrl)),
            const SizedBox(width: 8),
            Text(friend.uniqueId),
          ],
        ),
      ),
      body: Column(
        children: [
          // ✅ 메시지 리스트: AppBar 아래부터 위→아래로 쌓임
          Expanded(
            child: Obx(() {
              final msgs = controller.messages;
              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                itemCount: msgs.length,
                itemBuilder: (context, index) {
                  final msg = msgs[index];
                  final isMe = msg.senderId == my.uid;

                  return Align(
                    alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.blueAccent : Colors.grey.shade300,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(12),
                          topRight: const Radius.circular(12),
                          bottomLeft:
                              isMe
                                  ? const Radius.circular(12)
                                  : const Radius.circular(0),
                          bottomRight:
                              isMe
                                  ? const Radius.circular(0)
                                  : const Radius.circular(12),
                        ),
                      ),
                      child: Text(
                        msg.text,
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),

          // ✅ 하단 고정 입력창
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      onSubmitted: (value) {
                        final trimmed = value.trim();
                        if (trimmed.isNotEmpty) {
                          controller.sendMessage(trimmed);
                          messageController.clear();
                        }
                      },
                      decoration: InputDecoration(
                        hintText: '${friend.uniqueId}에게 메세지',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      final msg = messageController.text.trim();
                      if (msg.isNotEmpty) {
                        controller.sendMessage(msg);
                        messageController.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
