import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/data/repository/chat_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/private_chat/%08add_friend/add_friend_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/private_chat/private_chat_room/private_chat_room_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/private_chat/private_chat_room/private_chat_room_view_model.dart';

import 'package:what_is_your_eta/presentation/bottomNav/%08home/private_chat/private_chat_view_model.dart';

class PrivateChatView extends GetView<PrivateChatViewModel> {
  const PrivateChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return Column(
        children: [
          Text('${controller.userModel.value?.uniqueId}님 ㅎㅇ'),
          const Text('메세지'),
          ElevatedButton(
            onPressed: () {
              Get.to(() => AddFriendView(user: controller.userModel.value!));
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
                      : controller.friendList.map((e) {
                        return GestureDetector(
                          onTap: () {
                            Get.dialog(
                              AlertDialog(
                                title: Text('${e.name}님 정보'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('이름: ${e.name}'),
                                    Text('ID: ${e.uniqueId}'),
                                    ElevatedButton(
                                      onPressed: () async {
                                        Get.back();
                                        final chatRoomId = await controller
                                            .createChatRoom(e.uid);
                                        if (chatRoomId != null) {
                                          Get.delete<PrivateChatRoomViewModel>(
                                            force: true,
                                          ); // 💥 ViewModel 삭제
                                          Get.to(
                                            () => const PrivateChatRoomView(),
                                            arguments: chatRoomId,
                                            binding: BindingsBuilder(() {
                                              Get.put(
                                                PrivateChatRoomViewModel(
                                                  chatRepository:
                                                      Get.find<
                                                        ChatRepository
                                                      >(),
                                                  userRepository:
                                                      Get.find<
                                                        UserRepository
                                                      >(),
                                                  chatRoomId: chatRoomId,
                                                  my:
                                                      controller
                                                          .userModel
                                                          .value!,
                                                  friendUid: e.uid,
                                                ),
                                              );
                                            }),
                                          );
                                        } else {
                                          Get.snackbar(
                                            "에러",
                                            "채팅방을 생성할 수 없습니다.",
                                          );
                                        }
                                      },
                                      child: const Text('채팅 시작'),
                                    ),
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
                        );
                      }).toList(),
            ),
          ),
          Container(
            height: 300,
            width: 400,
            color: Colors.blue,
            child: Column(
              children:
                  controller.chatRoomList.map((chatRoom) {
                    return FutureBuilder<UserModel?>(
                      future: controller.getOpponentInfo(chatRoom),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox(height: 50);
                        }

                        final opponent = snapshot.data!;
                        final my = controller.userModel.value!;

                        return GestureDetector(
                          onTap: () {
                            Get.delete<PrivateChatRoomViewModel>(
                              force: true,
                            ); // 💥 삭제
                            Get.to(
                              () => const PrivateChatRoomView(),
                              arguments: chatRoom.id,
                              binding: BindingsBuilder(() {
                                Get.put(
                                  PrivateChatRoomViewModel(
                                    chatRepository: Get.find<ChatRepository>(),
                                    userRepository: Get.find<UserRepository>(),
                                    chatRoomId: chatRoom.id,
                                    my: my,
                                    friendUid: opponent.uid,
                                  ),
                                );
                              }),
                            );
                          },
                          child: Container(
                            width: 400,
                            color: Colors.red,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    opponent.photoUrl,
                                  ),
                                  radius: 16,
                                ),
                                const SizedBox(width: 8),
                                Text('${opponent.name}님과의 채팅방'),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
            ),
          ),
        ],
      );
    });
  }
}
