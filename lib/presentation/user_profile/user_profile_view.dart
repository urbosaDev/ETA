import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:what_is_your_eta/presentation/models/friend_info_model.dart';

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
            Get.offAllNamed('/main');
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

            // [수정] UseCase가 반환한 최종 상태 모델을 가져옵니다.
            final friendInfo = controller.friendInfo.value;

            // 데이터가 아직 로드되지 않은 경우
            if (friendInfo == null) {
              return const Center(
                child: Text(
                  '사용자 정보를 불러오는 중...',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            // [요구사항 반영] 탈퇴한 유저일 경우
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
                    // 친구 목록에 남아있을 경우, 친구 삭제 버튼이 활성화됩니다.
                    if (controller.isMyFriend.value)
                      ElevatedButton(
                        onPressed: () {
                          controller.deleteFriend();
                          // 친구 삭제 후 뒤로가기 또는 상태 갱신
                        },
                        child: Text('친구 목록에서 삭제'),
                      ),
                  ],
                ),
              );
            }

            // [요구사항 반영] 차단/정상 유저일 경우 (UI 구조는 동일)
            // UserModel.blocked() 또는 실제 UserModel이 friendInfo에 담겨있습니다.
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

  // [수정] 이제 controller.friendInfo에서 데이터를 가져옵니다.
  Widget _buildProfile(double profileSize) {
    return Obx(() {
      final photoUrl = controller.friendInfo.value?.userModel.photoUrl;
      return CircleAvatar(
        radius: profileSize / 2,
        backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
        // 필요 시 기본 이미지 추가
      );
    });
  }

  // [수정] 이제 controller.friendInfo에서 데이터를 가져옵니다.
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

  // [수정] 이제 controller.friendInfo와 isMyFriend로 상태를 판단합니다.
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
              // 탈퇴한 유저여도 내 친구 목록에 있다면 '친구 삭제' 메뉴 표시
              if (isFriend &&
                  (status == UserStatus.active || status == UserStatus.deleted))
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('친구 삭제', style: TextStyle(color: Colors.white)),
                ),
              // 정상 유저이고, 친구가 아닐 때만 '친구 추가' 메뉴 표시
              if (!isFriend && status == UserStatus.active)
                const PopupMenuItem<String>(
                  value: 'add',
                  child: Text('친구 추가', style: TextStyle(color: Colors.white)),
                ),
              // 탈퇴한 유저가 아닐 때만 차단/차단해제 메뉴 표시
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
        onSelected: (value) {
          /* onSelected 로직은 이전과 동일 */
        },
      );
    });
  }

  // [수정] 이제 controller.friendInfo.status로 차단 여부를 판단합니다.
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
          onPressed: canChat ? () => controller.createChatRoom() : null,
          // ... (style은 이전과 동일)
        ),
      );
    });
  }
}
