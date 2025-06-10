import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/location_repository.dart';
import 'package:what_is_your_eta/data/repository/promise_repository.dart';
import 'package:what_is_your_eta/domain/usecase/%08geo_current_location_usecase.dart';

import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/components/promise_tab_bar.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/location_share/calculate_distance_usecase.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/location_share/location_share_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/location_share/location_share_view_model.dart';
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
                Column(
                  children: [
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Get.to(
                              () =>
                                  const LocationShareView(), // 기존에 LocationShareModalView 대신 LocationShareView (Screen용으로 만들면 됨)
                              binding: BindingsBuilder(() {
                                Get.lazyPut(() => GetCurrentLocationUseCase());
                                Get.lazyPut(() => CalculateDistanceUseCase());
                                Get.lazyPut(
                                  () => LocationShareViewModel(
                                    promiseId: controller.promiseId,
                                    getCurrentLocationUseCase:
                                        Get.find<GetCurrentLocationUseCase>(),
                                    locationRepository:
                                        Get.find<LocationRepository>(),
                                    promiseRepository:
                                        Get.find<PromiseRepository>(),
                                    authRepository: Get.find<AuthRepository>(),
                                    calculateDistanceUseCase:
                                        Get.find<CalculateDistanceUseCase>(),
                                  ),
                                );
                              }),
                              transition:
                                  Transition.downToUp, // (선택) 모달 느낌 주고 싶으면
                              fullscreenDialog: true, // (선택) 모달처럼 보이게 할거면 true
                            );
                          },
                          child: const Text('위치 공유'),
                        ),
                      ],
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
