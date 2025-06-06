import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/add_vote_penalty/add_penalty_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/add_vote_penalty/penalty_container/penalty_container_view_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/add_vote_penalty/vote_penalty_view.dart';

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
                    onPageChanged:
                        (value) => controller.currentPage.value = value,
                    children: const [AddPenaltyView(), VotePenaltyView()],
                  );
                },
              ),
            ),

            Obx(
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
