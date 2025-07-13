import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/late/late_view_model.dart';
import 'package:what_is_your_eta/presentation/core/loading/common_loading_lottie.dart';
import 'package:what_is_your_eta/presentation/core/widget/user_tile.dart';
import 'package:what_is_your_eta/presentation/models/friend_info_model.dart';

class LateView extends GetView<LateViewModel> {
  const LateView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CommonLoadingLottie());
      }

      if (!controller.isAfterPromiseTime.value) {
        return Center(
          child: Text(
            '약속 시간이 지나면 열립니다 .',
            style: textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Text(
                    '도착한 친구들',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildUserSection(
                    context,
                    textTheme,
                    controller.arrivedUsers,
                  ),
                  const SizedBox(height: 16),
                  const Divider(
                    color: Colors.white12,
                    thickness: 0.2,
                    indent: 16,
                    endIndent: 16,
                  ),
                  Text(
                    '지각한 친구들',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildUserSection(context, textTheme, controller.lateUsers),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildUserSection(
    BuildContext context,
    TextTheme textTheme,

    List<FriendInfoModel> users,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff1a1a1a),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          if (users.isEmpty)
            Center(
              child: Text(
                '없음',
                style: textTheme.bodySmall?.copyWith(color: Colors.white70),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: UserTile(
                    user: user.userModel,
                    textTheme: textTheme,
                    isSelected: false,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
