import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/report_repository.dart';

import 'package:what_is_your_eta/presentation/report/report_view.dart';
import 'package:what_is_your_eta/presentation/report/report_view_model.dart';

Widget userInfoDialogView({
  required UserModel targetUser,
  required VoidCallback onChatPressed,
  required VoidCallback deleteFriend,
  required VoidCallback onBlockPressed,
  required VoidCallback onUnblockPressed,
  required bool isBlocked,
  required bool isUnknown,
}) {
  return AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.topRight,
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              Get.back();
              if (value == 'delete') {
                deleteFriend();
              } else if (value == 'block') {
                onBlockPressed();
              } else if (value == 'unblock') {
                onUnblockPressed();
              } else if (value == 'report') {
                Get.to(
                  () => ReportView(),
                  binding: BindingsBuilder(() {
                    Get.put(
                      ReportViewModel(
                        reportedId: targetUser.uid,
                        reportRepository: Get.find<ReportRepository>(),
                        authRepository: Get.find<AuthRepository>(),
                      ),
                    );
                  }),
                );
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('친구 삭제'),
                  ),
                  PopupMenuItem<String>(
                    value: isBlocked ? 'unblock' : 'block',
                    child: Text(isBlocked ? '차단 해제' : '차단하기'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'report',
                    child: Text('report user'),
                  ),
                ],
          ),
        ),
        // 프로필 이미지
        CircleAvatar(
          radius: 40,
          backgroundImage:
              isUnknown
                  ? const AssetImage('assets/imgs/default_profile.png')
                  : NetworkImage(targetUser.photoUrl),
        ),
        const SizedBox(height: 12),

        // 이름 + 유니크 ID
        Text(
          targetUser.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (!isUnknown)
          Text(
            '@${targetUser.uniqueId}',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),

        const SizedBox(height: 24),

        // 1:1 채팅 버튼 (unknown은 비활성화)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.chat_bubble_outline),
            label: Text(isBlocked ? '차단한 유저입니다' : '1:1 채팅'),
            onPressed: isBlocked || isUnknown ? null : onChatPressed,
          ),
        ),
      ],
    ),
    actions: [TextButton(onPressed: () => Get.back(), child: const Text('닫기'))],
  );
}
