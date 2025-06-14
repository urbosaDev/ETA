import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/data/repository/chat_repository.dart';
import 'package:what_is_your_eta/data/repository/fcm_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/private_chat/private_chat_room/private_chat_room_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/private_chat/private_chat_room/private_chat_room_view_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/private_chat/private_chat_view_model.dart';

Widget userInfoDialogView({
  required UserModel targetUser,
  required PrivateChatViewModel controller,
}) {
  return AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    // title: const Text("유저 정보", textAlign: TextAlign.center),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 프로필 이미지
        CircleAvatar(
          radius: 40,
          backgroundImage: NetworkImage(targetUser.photoUrl),
        ),
        const SizedBox(height: 12),

        // 이름 + 유니크 ID
        Text(
          targetUser.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          '@${targetUser.uniqueId}',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),

        const SizedBox(height: 24),

        // 1:1 채팅 버튼
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text("1:1 채팅"),
            onPressed: () async {
              Get.back();
              final chatRoomId = await controller.createChatRoom(
                targetUser.uid,
              );

              if (chatRoomId != null) {
                Get.to(
                  () => const PrivateChatRoomView(),
                  arguments: chatRoomId,
                  binding: BindingsBuilder(() {
                    Get.put(
                      PrivateChatRoomViewModel(
                        chatRepository: Get.find<ChatRepository>(),
                        userRepository: Get.find<UserRepository>(),
                        fcmRepository: Get.find<FcmRepository>(),
                        chatRoomId: chatRoomId,
                        my: controller.userModel.value!,
                        friendUid: targetUser.uid,
                      ),
                    );
                  }),
                );
              } else {
                Get.snackbar("에러", "채팅방 생성 실패");
              }
            },
          ),
        ),
      ],
    ),
    actions: [TextButton(onPressed: () => Get.back(), child: const Text('닫기'))],
  );
}
