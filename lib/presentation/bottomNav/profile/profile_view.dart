import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';

import 'package:what_is_your_eta/presentation/bottomNav/%08home/private_chat/%08add_friend/add_friend_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/bottom_nav_view_model.dart';

import 'package:what_is_your_eta/presentation/bottomNav/profile/profile_view_model.dart';

class ProfileView extends GetView<ProfileViewModel> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        final isLoading = controller.isLoading.value;
        final user = controller.userModel.value;
        final message = controller.errorMessage.value;
        final isNavigating = controller.isNavigating.value;
        if (message != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.snackbar(
              '알림',
              message,
              snackPosition: SnackPosition.TOP,
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.black.withOpacity(0.8),
              colorText: Colors.white,
              margin: const EdgeInsets.all(12),
            );
            controller.errorMessage.value = null;
          });
        }
        if (isNavigating) {
          return const Center(child: CircularProgressIndicator());
        }

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
            Text('탭해서 이동 스와이프해서 삭제'),
            Expanded(
              child: ListView.builder(
                itemCount: controller.unreadMessages.length,
                itemBuilder: (context, index) {
                  final msg = controller.unreadMessages[index];

                  return Dismissible(
                    key: Key(msg.id), // 유일한 키 필수
                    direction: DismissDirection.endToStart, // 오른쪽→왼쪽 스와이프
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) async {
                      await controller.deleteMessage(msg.id);
                      controller.unreadMessages.removeWhere(
                        (m) => m.id == msg.id,
                      );
                    },
                    child: ListTile(
                      title: Text(msg.title),
                      subtitle: Text(msg.body),
                      onTap: () async {
                        final groupId = msg.groupId;
                        await controller.markMessageAsRead(msg.id);
                        await controller.checkGroupNavigation(groupId);

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (controller.canEnterGroup.value) {
                            Get.find<BottomNavViewModel>().requestGoToGroup(
                              groupId,
                            );
                          }
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            // 이후 요소 추가 예정
            ElevatedButton(
              onPressed: () async {
                await controller.deleteAllMessagesAsRead();
              },
              child: const Text("알림 전체 읽음"),
            ),
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
}
