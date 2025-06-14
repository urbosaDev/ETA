import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/private_chat/%08add_friend/add_friend_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/profile/profile_view_model.dart';
import 'package:what_is_your_eta/presentation/core/dialog/user_info_dialog.dart';
import 'package:what_is_your_eta/presentation/core/widget/user_tile.dart';

class ProfileView extends GetView<ProfileViewModel> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        final isLoading = controller.isLoading.value;
        final user = controller.userModel.value;

        if (isLoading || user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(user),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Get.to(() => AddFriendView(user: controller.userModel.value!));
              },
              child: Text('친구 추가'),
            ),
            const SizedBox(height: 16),
            _buildFriendList(),
            // 이후 요소 추가 예정
          ],
        );
      }),
    );
  }

  Widget _buildProfileHeader(UserModel user) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // 원형 프로필 이미지
          CircleAvatar(
            radius: 32,
            backgroundImage: NetworkImage(user.photoUrl),
          ),
          const SizedBox(width: 16),
          // 이름과 아이디
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '@${user.uniqueId}',
                style: TextStyle(fontSize: 14, color: Colors.grey[400]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFriendList() {
    return Obx(() {
      final friends = controller.friendList;

      if (friends.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text("아직 친구가 없습니다.", style: TextStyle(color: Colors.grey)),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "내 친구들",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...friends.map((user) {
            return GestureDetector(
              onTap: () {
                Get.dialog(
                  userInfoDialogView(
                    targetUser: user,
                    createChatRoom: controller.createChatRoom,
                  ),
                );
              },
              child: UserTile(user: user),
            );
          }).toList(),
        ],
      );
    });
  }
}
