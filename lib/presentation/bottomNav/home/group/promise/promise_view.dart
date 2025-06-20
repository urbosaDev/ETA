import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/location_repository.dart';
import 'package:what_is_your_eta/data/repository/promise_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';
import 'package:what_is_your_eta/domain/usecase/%08geo_current_location_usecase.dart';
import 'package:what_is_your_eta/domain/usecase/location_share_usecase.dart';

import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/components/promise_tab_bar.dart';
import 'package:what_is_your_eta/domain/usecase/calculate_distance_usecase.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/location_share/location_share_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/location_share/location_share_view_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/promise_view_model.dart';

class PromiseView extends GetView<PromiseViewModel> {
  const PromiseView({super.key});

  @override
  Widget build(BuildContext context) {
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
                                  () => LocationShareUseCase(
                                    getCurrentLocationUseCase:
                                        Get.find<GetCurrentLocationUseCase>(),
                                    locationRepository:
                                        Get.find<LocationRepository>(),
                                    promiseRepository:
                                        Get.find<PromiseRepository>(),
                                    userRepository: Get.find<UserRepository>(),
                                    calculateDistanceUseCase:
                                        Get.find<CalculateDistanceUseCase>(),
                                  ),
                                );
                                Get.lazyPut(
                                  () => LocationShareViewModel(
                                    promiseId: controller.promiseId,
                                    locationShareUseCase:
                                        Get.find<LocationShareUseCase>(),
                                    promiseRepository:
                                        Get.find<PromiseRepository>(),
                                    authRepository: Get.find<AuthRepository>(),
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
