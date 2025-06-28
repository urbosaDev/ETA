import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/promise_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';
import 'package:what_is_your_eta/domain/usecase/calculate_distance_usecase.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/page1_info/promise_info_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/page1_info/promise_info_view_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/page2_late/late_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/page2_late/late_view_model.dart';

import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/promise_view_model.dart';

class PromiseView extends GetView<PromiseViewModel> {
  PromiseView({super.key});
  final PageController pageController = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('진행중인 약속')),
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
                    calculateDistanceUseCase:
                        Get.find<CalculateDistanceUseCase>(),
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
  }
}
