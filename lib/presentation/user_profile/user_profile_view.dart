import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';

import 'package:what_is_your_eta/data/repository/report_repository.dart';

import 'package:what_is_your_eta/presentation/bottomNav/%08home/private_chat/private_chat_room/private_chat_room_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/private_chat/private_chat_room/private_chat_room_view_model.dart';

import 'package:what_is_your_eta/presentation/models/friend_info_model.dart';
import 'package:what_is_your_eta/presentation/report/report_view.dart';
import 'package:what_is_your_eta/presentation/report/report_view_model.dart';

import 'package:what_is_your_eta/presentation/user_profile/user_profile_view_model.dart';

class UserProfileView extends GetView<UserProfileViewModel> {
  const UserProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [_buildPopupMenu()],
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final profileSize = width * 0.25;
          final buttonHeight = height * 0.055;

          return Obx(() {
            if (controller.isLoading.value ||
                controller.isRelationTransitioning.value) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            // if (controller.systemMessage.value != null) {
            //   WidgetsBinding.instance.addPostFrameCallback((_) {
            //     Get.snackbar(
            //       '알림',
            //       controller.systemMessage.value!,
            //       snackPosition: SnackPosition.TOP,
            //       backgroundColor: Colors.black,
            //       colorText: Colors.white,
            //     );
            //     controller.systemMessage.value = null;
            //   });
            // }

            final friendInfo = controller.friendInfo.value;

            if (friendInfo == null) {
              return const Center(
                child: Text(
                  '사용자 정보를 불러오는 중...',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            if (friendInfo.status == UserStatus.deleted) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '존재하지 않는 사용자입니다.',
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 40),

                    if (controller.isMyFriend.value)
                      ElevatedButton(
                        onPressed: () {
                          controller.deleteFriend();
                        },
                        child: Text('친구 목록에서 삭제'),
                      ),
                  ],
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.08,
                vertical: height * 0.08,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.04,
                      ),
                      _buildProfile(profileSize),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.04,
                      ),
                      _buildUserInfo(),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.08,
                      ),
                    ],
                  ),
                  _buildChatButton(buttonHeight),
                ],
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildProfile(double profileSize) {
    return Obx(() {
      final photoUrl = controller.friendInfo.value?.userModel.photoUrl;
      return CircleAvatar(
        radius: profileSize / 2,
        backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
      );
    });
  }

  Widget _buildUserInfo() {
    return Obx(() {
      final user = controller.friendInfo.value?.userModel;
      if (user == null) return const SizedBox.shrink();

      return Column(
        children: [
          Text(
            user.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '@${user.uniqueId}',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      );
    });
  }

  Widget _buildPopupMenu() {
    return Obx(() {
      final info = controller.friendInfo.value;
      if (info == null) return const SizedBox.shrink();

      final status = info.status;
      final isFriend = controller.isMyFriend.value;

      return PopupMenuButton<String>(
        color: const Color(0xFF1E1E1E),
        icon: const Icon(Icons.more_vert, color: Colors.white),
        itemBuilder:
            (context) => [
              if (isFriend &&
                  (status == UserStatus.active || status == UserStatus.deleted))
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('친구 삭제', style: TextStyle(color: Colors.white)),
                ),

              if (!isFriend && status == UserStatus.active)
                const PopupMenuItem<String>(
                  value: 'add',
                  child: Text('친구 추가', style: TextStyle(color: Colors.white)),
                ),

              if (status != UserStatus.deleted)
                PopupMenuItem<String>(
                  value: status == UserStatus.blocked ? 'unblock' : 'block',
                  child: Text(
                    status == UserStatus.blocked ? '차단 해제' : '차단하기',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              const PopupMenuItem<String>(
                value: 'report',
                child: Text('신고하기', style: TextStyle(color: Colors.red)),
              ),
            ],

        onSelected: (value) async {
          switch (value) {
            case 'add':
              await controller.addFriend();
              break;
            case 'delete':
              await controller.deleteFriend();
              break;
            case 'block':
              await controller.blockUserId();
              break;
            case 'unblock':
              await controller.unblockUserId();
              break;
            case 'report':
              Get.to(
                () => const ReportView(),
                binding: BindingsBuilder(() {
                  Get.put(
                    ReportViewModel(
                      reportedId: controller.targetUserUid,
                      reportRepository: Get.find<ReportRepository>(),
                      authRepository: Get.find<AuthRepository>(),
                    ),
                  );
                }),
              );
              break;
          }
        },
      );
    });
  }

  Widget _buildChatButton(double buttonHeight) {
    return Obx(() {
      final status = controller.friendInfo.value?.status;
      final canChat = status == UserStatus.active;

      return SizedBox(
        width: double.infinity,
        height: buttonHeight,
        child: OutlinedButton.icon(
          icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
          label: Text(
            status == UserStatus.blocked ? '차단한 유저입니다' : '1:1 채팅',
            style: const TextStyle(color: Colors.white),
          ),
          onPressed:
              canChat
                  ? () async {
                    final chatRoomId = await controller.createChatRoom();
                    if (chatRoomId != null) {
                      Get.off(
                        () => PrivateChatRoomView(),
                        arguments: chatRoomId,
                        binding: BindingsBuilder(() {
                          Get.put(
                            PrivateChatRoomViewModel(
                              chatRepository: Get.find(),
                              userRepository: Get.find(),
                              chatRoomId: chatRoomId,
                              myUid: controller.currentUserUid,
                              friendUid: controller.targetUserUid,
                            ),
                          );
                        }),
                      );
                    }
                  }
                  : null,
        ),
      );
    });
  }
}
