import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/lounge_in_group/lounge_in_group_view_model.dart';

class LoungeInGroupView extends GetView<LoungeInGroupViewModel> {
  const LoungeInGroupView({super.key});

  @override
  Widget build(BuildContext context) {
    final messageController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("속닥속닥 라운지")),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.memberMap.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              final msgs = controller.messages;
              return ListView.builder(
                itemCount: msgs.length,
                itemBuilder: (context, index) {
                  final msg = msgs[index];
                  final sender = controller.memberMap[msg.senderId];
                  if (sender == null) return const SizedBox(); // fallback 처리

                  final isMe = msg.senderId == controller.userModel.value?.uid;

                  return Align(
                    alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment:
                          isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                      children: [
                        if (!isMe)
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundImage: NetworkImage(sender.photoUrl),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                sender.name,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color:
                                isMe ? Colors.blueAccent : Colors.grey.shade300,
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
                      decoration: const InputDecoration(
                        hintText: '메세지를 입력하세요',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
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
