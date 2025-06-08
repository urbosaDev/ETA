import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/lounge_in_group/lounge_in_group_view_model.dart';
import 'package:what_is_your_eta/presentation/core/widget/chat/chat_input_box.dart';
import 'package:what_is_your_eta/presentation/core/widget/chat/chat_message_list_view.dart';

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
              return Expanded(
                child: ChatMessageListView(
                  messages: msgs,
                  userMap: controller.memberMap,
                  myUid: controller.userModel.value?.uid ?? '',
                ),
              );
            }),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: ChatInputBox(
                      controller: messageController,
                      onSend: (value) {
                        controller.sendMessage(value);
                        messageController.clear();
                      },
                    ),
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
