import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/promise_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/info/promise_info_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/info/promise_info_view_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/late/late_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/late/late_view_model.dart';

import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/promise_view_model.dart';

class PromiseView extends GetView<PromiseViewModel> {
  PromiseView({super.key});
  final PageController pageController = PageController();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // 초기화 전이면 로딩 상태로
      if (controller.isLoading.value && controller.promise.value == null) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      return Scaffold(
        appBar: AppBar(title: Text(controller.promise.value?.name ?? '약속')),
        body: Column(
          children: [
            Expanded(
              child: PageView(
                controller: pageController,
                onPageChanged: controller.setCurrentPage,
                children: [
                  GetBuilder<PromiseInfoViewModel>(
                    init: PromiseInfoViewModel(
                      promiseId: controller.promiseId,
                      promiseRepository: Get.find<PromiseRepository>(),
                      userRepository: Get.find<UserRepository>(),
                    ),
                    autoRemove: true,
                    builder: (c) => PromiseInfoView(),
                  ),
                  GetBuilder<LateViewModel>(
                    init: LateViewModel(
                      promiseId: controller.promiseId,
                      promiseRepository: Get.find<PromiseRepository>(),
                      userRepository: Get.find<UserRepository>(),
                      authRepository: Get.find<AuthRepository>(),
                    ),
                    autoRemove: true,
                    builder: (c) => LateView(),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 60,
              child: Center(
                child: Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(2, (index) {
                      final isSelected = controller.currentPage.value == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isSelected ? 12 : 8,
                        height: isSelected ? 12 : 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? Colors.greenAccent : Colors.grey,
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// if (controller.isLoading.value) return const SizedBox();
//             return Column(
//               children: [
//                 PromiseTabBar(promiseId: controller.promiseId),

//                 Column(
//                   children: [
//                     Row(
//                       children: [
//                         ElevatedButton(
//                           onPressed: () {
//                             Get.to(
//                               () =>
//                                   const LocationShareView(), // 기존에 LocationShareModalView 대신 LocationShareView (Screen용으로 만들면 됨)
//                               binding: BindingsBuilder(() {
//                                 Get.lazyPut(() => GetCurrentLocationUseCase());
//                                 Get.lazyPut(() => CalculateDistanceUseCase());
//                                 Get.lazyPut(
//                                   () => LocationShareUseCase(
//                                     getCurrentLocationUseCase:
//                                         Get.find<GetCurrentLocationUseCase>(),
//                                     locationRepository:
//                                         Get.find<LocationRepository>(),
//                                     promiseRepository:
//                                         Get.find<PromiseRepository>(),
//                                     userRepository: Get.find<UserRepository>(),
//                                     calculateDistanceUseCase:
//                                         Get.find<CalculateDistanceUseCase>(),
//                                     groupRepository:
//                                         Get.find<GroupRepository>(),
//                                   ),
//                                 );
//                                 Get.lazyPut(
//                                   () => LocationShareViewModel(
//                                     promiseId: controller.promiseId,
//                                     locationShareUseCase:
//                                         Get.find<LocationShareUseCase>(),
//                                     promiseRepository:
//                                         Get.find<PromiseRepository>(),
//                                     authRepository: Get.find<AuthRepository>(),
//                                   ),
//                                 );
//                               }),
//                               transition:
//                                   Transition.downToUp, // (선택) 모달 느낌 주고 싶으면
//                               fullscreenDialog: true, // (선택) 모달처럼 보이게 할거면 true
//                             );
//                           },
//                           child: const Text('위치 공유'),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ],
//             );
