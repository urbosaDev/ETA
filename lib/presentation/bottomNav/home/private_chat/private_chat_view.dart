import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/private_chat/%08add_friend/add_friend_view.dart';

import 'package:what_is_your_eta/presentation/bottomNav/%08home/private_chat/private_chat_view_model.dart';

class PrivateChatView extends GetView<PrivateChatViewModel> {
  const PrivateChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      return Column(
        children: [
          Text('${controller.userModel?.uniqueId}님 ㅎㅇ'),
          const Text('메세지'),
          ElevatedButton(
            onPressed: () {
              Get.to(() => AddFriendView(user: controller.userModel!));
            },
            child: const Text("친구 추가하기"),
          ),
          Container(
            height: 100,
            color: Colors.grey,
            child: Row(
              children:
                  controller.friendList.isEmpty
                      ? [const Text('친구가 없습니다.')]
                      : controller.friendList.map((e) => Text(e.name)).toList(),
            ),
          ),
          Container(height: 300, color: Colors.blue),
        ],
      );
    });
  }
}
