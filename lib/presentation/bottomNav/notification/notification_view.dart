import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';

import 'package:what_is_your_eta/presentation/bottomNav/bottom_nav_view_model.dart';

import 'package:what_is_your_eta/presentation/bottomNav/notification/notification_view_model.dart';
import 'package:what_is_your_eta/presentation/core/loading/common_loading_lottie.dart';

class NotificationView extends GetView<NotificationViewModel> {
  const NotificationView({super.key});

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
          return const Center(child: CommonLoadingLottie());
        }

        if (isLoading || user == null) {
          return const Center(child: CommonLoadingLottie());
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('알림', style: TextTheme.of(context).titleLarge),
              const SizedBox(height: 16),
              _buildProfileHeader(context, user),
              const SizedBox(height: 8),
              const Divider(color: Colors.grey, thickness: 0.2),
              const SizedBox(height: 16),

              const SizedBox(height: 16),
              Center(
                child: Text(
                  '탭해서 이동 스와이프해서 삭제',
                  style: TextTheme.of(context).bodySmall,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: controller.unreadMessages.length,
                  itemBuilder: (context, index) {
                    final msg = controller.unreadMessages[index];

                    return Dismissible(
                      key: Key(msg.id),
                      direction: DismissDirection.endToStart,
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
                      child: _buildDiscordStyleNotification(
                        context,
                        title: msg.title,
                        body: msg.body,
                        timeText: controller.formatNotificationTime(
                          msg.createdAt,
                        ),
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

              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await controller.deleteAllMessagesAsRead();
                  },
                  child: const Text("알림 전체 읽음"),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserModel user) {
    return Row(
      children: [
        CircleAvatar(radius: 22, backgroundImage: NetworkImage(user.photoUrl)),
        const SizedBox(width: 16),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.name, style: TextTheme.of(context).bodyMedium),
            const SizedBox(height: 4),
            Text('@${user.uniqueId}', style: TextTheme.of(context).bodySmall),
          ],
        ),
      ],
    );
  }

  Widget _buildDiscordStyleNotification(
    BuildContext context, {
    required String title,
    required String body,
    required String timeText,
    required VoidCallback onTap,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xff1a1a1a),
        borderRadius: BorderRadius.circular(12),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.notifications, color: Colors.white70, size: 20),

            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,

                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 2),
                  Text(
                    body,

                    style: textTheme.bodySmall?.copyWith(color: Colors.white70),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),
                  Text(
                    timeText,

                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
