import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/components/promise_tab_bar.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/promise_view_model.dart';
import 'package:what_is_your_eta/presentation/core/widget/chat/chat_input_box.dart';
import 'package:what_is_your_eta/presentation/core/widget/chat/chat_message_list_view.dart';

class PromiseView extends GetView<PromiseViewModel> {
  const PromiseView({super.key});

  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final title = controller.promise.value?.name ?? '약속';
          return Text(title);
        }),
      ),
      body: Stack(
        children: [
          // 실제 컨텐츠
          Obx(() {
            if (controller.isLoading.value) return const SizedBox();
            return Column(
              children: [
                PromiseTabBar(promiseId: controller.promiseId),
                Expanded(
                  child: ChatMessageListView(
                    messages: controller.messages,
                    userMap: controller.memberMap,
                    myUid: controller.userModel.value?.uid ?? '',
                  ),
                ),
                ChatInputBox(
                  controller: textController,
                  onSend: (msg) async {
                    await controller.sendMessage(msg);
                    textController.clear();
                    FocusScope.of(context).unfocus();
                  },
                ),
              ],
            );
          }),

          // 로딩 인디케이터만 별도
          Obx(() {
            return controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : const SizedBox();
          }),
        ],
      ),
    );
  }
}
