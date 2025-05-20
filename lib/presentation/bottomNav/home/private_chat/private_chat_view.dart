import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/private_chat/%08add_friend/add_friend_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/private_chat/private_chat_room/private_chat_room_view.dart';

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
                      : controller.friendList
                          .map(
                            (e) => GestureDetector(
                              onTap: () {
                                Get.dialog(
                                  AlertDialog(
                                    title: Text('${e.name}님 정보'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('이름: ${e.name}'),
                                        Text('ID: ${e.uniqueId}'),
                                        ElevatedButton(
                                          onPressed: () async {
                                            Get.back();
                                            final chatRoomId = await controller
                                                .createChatRoom(e.uid);
                                            if (chatRoomId != null) {
                                              Get.to(
                                                () => PrivateChatRoomView(
                                                  chatRoomId: chatRoomId,
                                                  my: controller.userModel!,
                                                  friend: e,
                                                ),
                                              );
                                            } else {
                                              Get.snackbar(
                                                "에러",
                                                "채팅방을 생성할 수 없습니다.",
                                              );
                                            }
                                          },
                                          child: Text('채팅시작'),
                                        ),
                                        // 필요한 다른 정보 추가 가능
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Get.back(),
                                        child: const Text('닫기'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Container(
                                width: 60,
                                height: 60,
                                color: Colors.yellow,
                                child: Text(e.name),
                              ),
                            ),
                          )
                          .toList(),
            ),
          ),
          Container(height: 300, color: Colors.blue),
        ],
      );
    });
  }
}
