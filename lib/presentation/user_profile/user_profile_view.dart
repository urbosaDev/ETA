import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/chat_repository.dart';
import 'package:what_is_your_eta/data/repository/report_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';

import 'package:what_is_your_eta/presentation/bottomNav/%08home/private_chat/private_chat_room/private_chat_room_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/private_chat/private_chat_room/private_chat_room_view_model.dart';
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
          onPressed: () => Get.back(),
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

            if (controller.systemMessage.value != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Get.snackbar(
                  '알림',
                  controller.systemMessage.value!,
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Colors.black,
                  colorText: Colors.white,
                );
                controller.systemMessage.value = null;
              });
            }

            if (controller.targetUserModel.value == null ||
                controller.relationStatus.value == UserRelationStatus.unknown) {
              return const Center(
                child: Text(
                  '유저 정보를 불러올 수 없습니다.',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
            final chatId = controller.navigateToChatRoomId.value;
            if (chatId != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Get.off(
                  () => PrivateChatRoomView(),
                  fullscreenDialog: true,
                  transition: Transition.rightToLeft,
                  binding: BindingsBuilder(() {
                    Get.put(
                      PrivateChatRoomViewModel(
                        chatRepository: Get.find<ChatRepository>(),
                        chatRoomId: chatId,
                        friendUid: controller.targetUserUid,
                        myUid: controller.currentUserUid,
                        userRepository: Get.find<UserRepository>(),
                      ),
                    );
                  }),
                );
              });
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

  Widget _buildProfile(profileSize) {
    return Obx(() {
      final photoUrl = controller.targetUserModel.value?.photoUrl;
      return CircleAvatar(
        radius: profileSize / 2,
        backgroundImage:
            photoUrl != null
                ? NetworkImage(photoUrl)
                : const AssetImage('assets/imgs/default_profile.png')
                    as ImageProvider,
      );
    });
  }

  Widget _buildUserInfo() {
    return Obx(() {
      final name = controller.targetUserModel.value!.name;
      final uid = controller.targetUserModel.value!.uniqueId;
      return Column(
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '@$uid',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      );
    });
  }

  Widget _buildPopupMenu() {
    return Align(
      alignment: Alignment.topRight,
      child: Obx(() {
        final isFriend = controller.isMyFriend.value;
        final relation = controller.relationStatus.value;

        return PopupMenuButton<String>(
          color: const Color(0xFF1E1E1E),
          icon: const Icon(Icons.more_vert, color: Colors.white),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          itemBuilder:
              (context) => [
                if (relation != UserRelationStatus.unknown)
                  PopupMenuItem<String>(
                    value: isFriend ? 'delete' : 'add',
                    child: Row(
                      children: [
                        Icon(
                          isFriend ? Icons.person_remove : Icons.person_add,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isFriend ? '친구 삭제' : '친구 추가',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                if (relation == UserRelationStatus.blocked ||
                    relation == UserRelationStatus.normal)
                  PopupMenuItem<String>(
                    value:
                        relation == UserRelationStatus.blocked
                            ? 'unblock'
                            : 'block',
                    child: Row(
                      children: [
                        Icon(
                          relation == UserRelationStatus.blocked
                              ? Icons.lock_open
                              : Icons.block,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          relation == UserRelationStatus.blocked
                              ? '차단 해제'
                              : '차단하기',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                const PopupMenuItem<String>(
                  value: 'report',
                  child: Row(
                    children: [
                      Icon(
                        Icons.report_gmailerrorred,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Text('신고하기', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
          onSelected: (value) {
            switch (value) {
              case 'add':
                controller.addFriend();
                break;
              case 'delete':
                controller.deleteFriend();
                break;
              case 'block':
                controller.blockUserId();

                break;
              case 'unblock':
                controller.unblockUserId();
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
      }),
    );
  }

  Widget _buildChatButton(buttonHeight) {
    return Obx(() {
      final isBlocked =
          controller.relationStatus.value == UserRelationStatus.blocked;

      return SizedBox(
        width: double.infinity,
        height: buttonHeight,
        child: OutlinedButton.icon(
          icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
          label: Text(
            isBlocked ? '차단한 유저입니다' : '1:1 채팅',
            style: const TextStyle(color: Colors.white),
          ),
          onPressed:
              isBlocked
                  ? null
                  : () {
                    controller.createChatRoom();
                  },
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.05),
            side: const BorderSide(color: Color(0xFF444444)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
    });
  }
}
