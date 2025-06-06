import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/promise_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/add_vote_penalty/penalty_container/penalty_container_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/add_vote_penalty/penalty_container/penalty_container_view_model.dart';

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
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Get.to(
                          () => const PenaltyContainerView(),
                          transition: Transition.downToUp,
                          opaque: false,
                          duration: const Duration(milliseconds: 300),
                          fullscreenDialog: true,
                          binding: BindingsBuilder(() {
                            Get.put(
                              PenaltyContainerViewModel(
                                promiseId: controller.promiseId,
                                promiseRepository:
                                    Get.find<PromiseRepository>(),
                                userRepository: Get.find<UserRepository>(),
                                authRepository: Get.find<AuthRepository>(),
                              ),
                            );
                          }),
                        );
                      },
                      child: const Text('벌칙생성'),
                    ),
                    Expanded(
                      child: ChatInputBox(
                        controller: textController,
                        onSend: (msg) async {
                          await controller.sendMessage(msg);
                          textController.clear();
                          FocusScope.of(context).unfocus();
                        },
                      ),
                    ),
                  ],
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
