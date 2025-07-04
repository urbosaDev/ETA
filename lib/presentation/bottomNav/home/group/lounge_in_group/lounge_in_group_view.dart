import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/lounge_in_group/lounge_in_group_view_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/promise_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/promise_view_model.dart';
import 'package:what_is_your_eta/presentation/core/widget/chat/chat_input_box.dart';
import 'package:what_is_your_eta/presentation/core/widget/chat/chat_message_list_view.dart';

class LoungeInGroupView extends GetView<LoungeInGroupViewModel> {
  final messageController = TextEditingController();
  LoungeInGroupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Obx(() {
            final promiseId = controller.currentPromiseId.value;
            final isEnabled = promiseId != null;

            return Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: TextButton(
                onPressed:
                    isEnabled
                        ? () {
                          Get.to(
                            () => PromiseView(),
                            binding: BindingsBuilder(() {
                              Get.put(PromiseViewModel(promiseId: promiseId));
                            }),
                          );
                        }
                        : null, // null이면 비활성화됨
                style: TextButton.styleFrom(
                  backgroundColor:
                      isEnabled ? Colors.blue : Colors.grey.shade300,
                  foregroundColor:
                      isEnabled ? Colors.white : Colors.grey.shade600,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(isEnabled ? "약속 보기" : "약속 없음"),
              ),
            );
          }),
        ],
      ),
      body: Column(
        children: [
          // Expanded(
          //   child: Obx(() {
          //     if (controller.memberMap.isEmpty) {
          //       return const Center(child: CircularProgressIndicator());
          //     }

          //     final msgs = controller.messages;
          //     return Expanded(
          //       child: ChatMessageListView(
          //         messages: msgs,
          //         userMap: controller.memberMap,
          //         myUid: controller.userModel.value?.uid ?? '',
          //         onReachedTop: () {
          //           // controller.loadMore();
          //         },
          //       ),
          //     );
          //   }),
          // ),
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
