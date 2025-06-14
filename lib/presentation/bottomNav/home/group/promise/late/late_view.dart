import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/late/late_view_model.dart';
import 'package:what_is_your_eta/presentation/core/widget/user_tile.dart';

class LateView extends GetView<LateViewModel> {
  const LateView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('지각자 목록')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!controller.isAfterPromiseTime.value) {
          return const Center(child: Text('약속 시간이 아직 지나지 않았습니다.'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                children: [
                  _buildUserSection('도착한 친구들', controller.arrivedUsers),
                  const Divider(),
                  _buildUserSection('지각한 친구들', controller.lateUsers),
                ],
              ),
            ),
            const Divider(),
            _buildPenaltySection(),
          ],
        );
      }),
    );
  }

  Widget _buildUserSection(String title, List<UserModel> users) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          if (users.isEmpty) const Text('없음'),
          ...users.map((user) => UserTile(user: user)),
        ],
      ),
    );
  }

  Widget _buildPenaltySection() {
    final penalty = controller.promise.value?.selectedPenalty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
      child: Text(
        penalty != null ? '벌칙: ${penalty.description}' : '벌칙이 정해지지 않았습니다.',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}
