import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/add_vote_penalty/components/swipe_hint.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/add_vote_penalty/penalty_container/view_penalty/view_penalty_view_model.dart';

class ViewPenaltyView extends GetView<ViewPenaltyViewModel> {
  const ViewPenaltyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Obx(() {
        if (controller.isLoading.value) {
          return const CircularProgressIndicator();
        }

        final hasSelected = controller.hasSelectedPenalty;
        if (hasSelected) {
          // 벌칙이 정해진 경우 화면 구성
          final selectedPenalty = controller.promise.value?.selectedPenalty;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '✅ 최종 벌칙',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '"${selectedPenalty?.description}"',
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
            ],
          );
        } else {
          // 아직 벌칙이 없는 경우 → 스와이프 유도 화면 구성
          return Column(
            children: [
              const Text(
                '아직 최종 벌칙이 정해지지 않았습니다.\n벌칙 탭으로 이동하여 제안 및 투표를 진행해주세요!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SwipeHint(icon: Icons.arrow_back_ios, label: '벌칙 제안탭'),
            ],
          );
        }
      }),
    );
  }
}
