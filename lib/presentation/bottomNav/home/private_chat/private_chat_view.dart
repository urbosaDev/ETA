import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/data/repository/chat_repository.dart';

import 'package:what_is_your_eta/data/repository/user_%08repository.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/private_chat/%08add_friend/add_friend_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/private_chat/private_chat_room/private_chat_room_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/private_chat/private_chat_room/private_chat_room_view_model.dart';

import 'package:what_is_your_eta/presentation/bottomNav/%08home/private_chat/private_chat_view_model.dart';
import 'package:what_is_your_eta/presentation/core/dialog/user_info_dialog.dart';

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
                      : controller.friendList.map((user) {
                        return GestureDetector(
                          onTap: () {
                            Get.dialog(
                              userInfoDialogView(
                                isBlocked: user.isBlocked,
                                onBlockPressed: () async {
                                  await controller.blockUserId(
                                    friendUid: user.userModel.uid,
                                  );
                                },
                                onUnblockPressed: () async {
                                  await controller.unblockUserId(
                                    friendUid: user.userModel.uid,
                                  );
                                },
                                isUnknown: user.userModel.uniqueId == 'unknown',
                                targetUser: user.userModel,
                                deleteFriend: () async {
                                  await controller.removeFriend(
                                    friendUid: user.userModel.uid,
                                  );
                                },
                                onChatPressed: () async {
                                  final chatRoomId = await controller
                                      .createChatRoom(user.userModel.uid);
                                  if (controller.navigateToChat.value) {
                                    WidgetsBinding.instance.addPostFrameCallback((
                                      _,
                                    ) {
                                      controller.resetNavigateToChat();
                                      Get.back(); // 다이얼로그 닫기
                                      Get.to(
                                        () => PrivateChatRoomView(),
                                        binding: BindingsBuilder(() {
                                          Get.put(
                                            PrivateChatRoomViewModel(
                                              chatRoomId: chatRoomId!,
                                              friendUid: user.userModel.uid,
                                              chatRepository:
                                                  Get.find<ChatRepository>(),
                                              // fcmRepository:
                                              //     Get.find<FcmRepository>(),
                                              userRepository:
                                                  Get.find<UserRepository>(),
                                              myUid:
                                                  controller
                                                      .userModel
                                                      .value!
                                                      .uid,
                                            ),
                                          );
                                        }),
                                      );
                                    });
                                  }
                                },
                              ),
                            );
                          },
                          child: Container(
                            width: 60,
                            height: 60,
                            color: Colors.yellow,
                            child: Text(user.userModel.name),
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
                            Get.to(
                              () => const PrivateChatRoomView(),
                              arguments: chatRoom.id,
                              binding: BindingsBuilder(() {
                                Get.put(
                                  PrivateChatRoomViewModel(
                                    chatRepository: Get.find<ChatRepository>(),
                                    userRepository: Get.find<UserRepository>(),
                                    // fcmRepository: Get.find<FcmRepository>(),
                                    chatRoomId: chatRoom.id,
                                    myUid: my.uid,
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
