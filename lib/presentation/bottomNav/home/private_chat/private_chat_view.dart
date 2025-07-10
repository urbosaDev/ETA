import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/chat_repository.dart';

import 'package:what_is_your_eta/data/repository/user_%08repository.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/private_chat/%08add_friend/add_friend_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/private_chat/private_chat_room/private_chat_room_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/private_chat/private_chat_room/private_chat_room_view_model.dart';

import 'package:what_is_your_eta/presentation/bottomNav/%08home/private_chat/private_chat_view_model.dart';
import 'package:what_is_your_eta/presentation/core/loading/common_loading_lottie.dart';
import 'package:what_is_your_eta/presentation/core/widget/%08user_card.dart';
import 'package:what_is_your_eta/presentation/user_profile/user_profile_view.dart';
import 'package:what_is_your_eta/presentation/user_profile/user_profile_view_model.dart';

class PrivateChatView extends GetView<PrivateChatViewModel> {
  const PrivateChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CommonLoadingLottie());
      }

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '메시지',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {
                  if (controller.userModel.value != null) {
                    Get.to(
                      () => AddFriendView(user: controller.userModel.value!),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xff1a1a1a),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_add,
                        color: Color(0xffa8216b),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "친구 추가하기",
                        style: textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Color(0xffa8216b),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const Divider(color: Colors.white12, thickness: 0.2),

            Container(
              height: screenWidth * 0.25,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xff1a1a1a),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12, width: 0.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Obx(() {
                if (controller.friendList.isEmpty) {
                  return Center(
                    child: Text(
                      '아직 친구가 없습니다.',
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  );
                } else {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal, // 가로 스크롤
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      children:
                          controller.friendList.map((friendInfo) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: GestureDetector(
                                onTap: () {
                                  Get.to(
                                    () => const UserProfileView(),
                                    fullscreenDialog: true,
                                    transition: Transition.downToUp,
                                    binding: BindingsBuilder(() {
                                      Get.put(
                                        UserProfileViewModel(
                                          userRepository:
                                              Get.find<UserRepository>(),
                                          authRepository:
                                              Get.find<AuthRepository>(),
                                          chatRepository:
                                              Get.find<ChatRepository>(),
                                          targetUserUid:
                                              friendInfo.userModel.uid,
                                        ),
                                      );
                                    }),
                                  );
                                },
                                child: UserSquareCard(
                                  user: friendInfo.userModel,
                                  size: screenWidth * 0.15,
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  );
                }
              }),
            ),
            Row(
              children: [
                Text(
                  '채팅방 목록',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Text(
                  '스와이프 해서 나가기',
                  style: textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
              ],
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xff1a1a1a), // 배경색
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12, width: 0.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Obx(() {
                  final chatRoomList = controller.chatRoomList;
                  if (chatRoomList.isNotEmpty) {
                    return ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: controller.chatRoomList.length,
                      separatorBuilder:
                          (context, index) => const Divider(
                            color: Colors.white12,
                            thickness: 0.2,
                            indent: 16,
                            endIndent: 16,
                          ),
                      itemBuilder: (context, index) {
                        final displayModel = controller.chatRoomList[index];
                        // displayModel.chatRoom
                        final chatRoom = displayModel.chatRoom;
                        final opponent = displayModel.opponentUser;
                        final my = controller.userModel.value!;
                        return Slidable(
                          key: ValueKey(chatRoom.id),
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            extentRatio: 0.25,
                            children: [
                              SlidableAction(
                                onPressed: (context) {
                                  Get.defaultDialog(
                                    backgroundColor: Color(0xff1a1a1a),
                                    title: '채팅방 나가기',
                                    middleText:
                                        '정말로 이 채팅방을 나가시겠습니까? \n대화 기록은 삭제됩니다.',
                                    textConfirm: '나가기',
                                    textCancel: '취소',
                                    confirmTextColor: Colors.white,
                                    cancelTextColor: Colors.white,
                                    buttonColor: Colors.redAccent,
                                    radius: 8.0,
                                    onConfirm: () async {
                                      Get.back();
                                      await controller.leaveChatRoom(
                                        chatRoom.id,
                                      );
                                    },
                                  );
                                },
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.exit_to_app,
                                label: '나가기',
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 15,
                              backgroundImage: NetworkImage(opponent.photoUrl),
                              backgroundColor: Colors.grey[700],
                            ),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '@${opponent.uniqueId}',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '${opponent.name}님과의 채팅방',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),

                            onTap: () {
                              if (opponent.uniqueId != 'unknown') {
                                Get.to(
                                  () => PrivateChatRoomView(),
                                  arguments: chatRoom.id,
                                  binding: BindingsBuilder(() {
                                    Get.put(
                                      PrivateChatRoomViewModel(
                                        chatRepository:
                                            Get.find<ChatRepository>(),
                                        userRepository:
                                            Get.find<UserRepository>(),
                                        chatRoomId: chatRoom.id,
                                        myUid: my.uid,
                                        friendUid: opponent.uid,
                                      ),
                                    );
                                  }),
                                );
                              }
                            },
                          ),
                        );
                      },
                    );
                  } else {
                    return Center(
                      child: Text(
                        '아직 채팅방이 없습니다.',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    );
                  }
                }),
              ),
            ),
          ],
        ),
      );
    });
  }
}
