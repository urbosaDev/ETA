import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:what_is_your_eta/presentation/bottomNav/%08home/private_chat/private_chat_room/private_chat_room_view_model.dart';
import 'package:what_is_your_eta/presentation/core/widget/chat/chat_input_box.dart';
import 'package:what_is_your_eta/presentation/core/widget/chat/chat_message_list_view.dart';

class PrivateChatRoomView extends GetView<PrivateChatRoomViewModel> {
  const PrivateChatRoomView({super.key});

  @override
  Widget build(BuildContext context) {
    final messageController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // 기존 뒤로가기 버튼 제거
        title: Obx(() {
          final friend = controller.friendModel.value;
          if (friend == null) return const Text('로딩 중...');

          return Row(
            children: [
              // 새로 만든 수동 뒤로가기 버튼
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  // Get.back(); // 채팅방 뷰 pop
                  // final homeViewModel = Get.find<HomeViewModel>();
                  // homeViewModel.changeSideTabIndex(0);
                  Get.offAllNamed('/main');
                },
              ),
              const SizedBox(width: 8),
              CircleAvatar(backgroundImage: NetworkImage(friend.photoUrl)),
              const SizedBox(width: 8),
              Text(friend.name),
            ],
          );
        }),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final msgs = controller.messages;
              final friend = controller.friendModel.value;
              if (friend == null) {
                return const Center(child: CircularProgressIndicator());
              }

              // 개인 채팅에서는 유저맵을 간단히 구성
              final userMap = {
                controller.myUid: controller.myModel.value!,
                friend.uid: controller.friendModel.value!,
              };

              return ChatMessageListView(
                messages: msgs,
                userMap: userMap,
                myUid: controller.myUid,
              );
            }),
          ),
          ChatInputBox(
            controller: messageController,
            onSend: (value) {
              controller.sendMessage(value);
              messageController.clear();
            },
          ),
        ],
      ),
    );
  }
}
