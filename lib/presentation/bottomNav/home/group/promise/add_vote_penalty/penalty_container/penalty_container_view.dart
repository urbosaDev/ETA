import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/promise_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/add_vote_penalty/penalty_container/add_penalty/add_penalty_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/add_vote_penalty/penalty_container/add_penalty/add_penalty_view_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/add_vote_penalty/penalty_container/penalty_container_view_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/add_vote_penalty/penalty_container/view_penalty/view_penalty_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/add_vote_penalty/penalty_container/view_penalty/view_penalty_view_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/add_vote_penalty/penalty_container/vote_penalty/vote_penalty_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/add_vote_penalty/penalty_container/vote_penalty/vote_penalty_view_model.dart';

class PenaltyContainerView extends GetView<PenaltyContainerViewModel> {
  const PenaltyContainerView({super.key});

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController();

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(title: const Text('벌칙 추가')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GetBuilder<PenaltyContainerViewModel>(
                builder: (controller) {
                  return PageView(
                    controller: pageController,
                    onPageChanged: (value) {
                      controller.setCurrentPage(value);
                    },
                    children: [
                      GetBuilder(
                        init: ViewPenaltyViewModel(
                          promiseId: controller.promiseId,
                          promiseRepository: Get.find<PromiseRepository>(),
                        ),
                        autoRemove: true,
                        builder: (controller) => ViewPenaltyView(),
                      ),
                      GetBuilder(
                        init: AddPenaltyViewModel(
                          promiseId: controller.promiseId,
                          promiseRepository: Get.find<PromiseRepository>(),
                          userRepository: Get.find<UserRepository>(),
                          authRepository: Get.find<AuthRepository>(),
                        ),
                        autoRemove: true,
                        builder: (controller) => AddPenaltyView(),
                      ),
                      GetBuilder(
                        init: VotePenaltyViewModel(
                          promiseId: controller.promiseId,
                          promiseRepository: Get.find<PromiseRepository>(),
                          userRepository: Get.find<UserRepository>(),
                          authRepository: Get.find<AuthRepository>(),
                        ),
                        autoRemove: true,
                        builder: (controller) => VotePenaltyView(),
                      ),
                    ],
                  );
                },
              ),
            ),

            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  final isSelected = controller.currentPage.value == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isSelected ? 12 : 8,
                    height: isSelected ? 12 : 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? Colors.white : Colors.grey,
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
