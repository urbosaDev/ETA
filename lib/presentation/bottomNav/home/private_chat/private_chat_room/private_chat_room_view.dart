import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:what_is_your_eta/presentation/bottomNav/%08home/private_chat/private_chat_room/private_chat_room_view_model.dart';

class PrivateChatRoomView extends GetView<PrivateChatRoomViewModel> {
  const PrivateChatRoomView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PrivateChatRoomViewModel>();
    final messageController = TextEditingController();

    return WillPopScope(
      onWillPop: () async {
        Get.delete<PrivateChatRoomViewModel>();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Obx(() {
            final friend = controller.friendModel.value;
            if (friend == null) return const Text('로딩 중...');

            return Row(
              children: [
                CircleAvatar(backgroundImage: NetworkImage(friend.photoUrl)),
                const SizedBox(width: 8),
                Text(friend.name),
              ],
            );
          }),
        ),
        body: Column(
          children: [
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
                    final isMe = msg.senderId == controller.my.uid;
                    final friend = controller.friendModel.value;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment:
                            isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                        children: [
                          if (!isMe && friend != null)
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundImage: NetworkImage(
                                    friend.photoUrl,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  friend.name,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color:
                                  isMe
                                      ? Colors.blueAccent
                                      : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              msg.text,
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
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
                          hintText: '메세지를 입력하세요',
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
      ),
    );
  }
}
