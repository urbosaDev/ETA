import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/chat_repository.dart';
import 'package:what_is_your_eta/data/repository/fcm_repository.dart';

import 'package:what_is_your_eta/data/repository/group_repository.dart';
import 'package:what_is_your_eta/data/repository/promise_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';

import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/group_view_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/lounge_in_group/lounge_in_group_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/lounge_in_group/lounge_in_group_view_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/promise_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/promise_view_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/private_chat/private_chat_room/private_chat_room_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/private_chat/private_chat_room/private_chat_room_view_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/promise/create_promise/create_promise_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/promise/create_promise/create_promise_view_model.dart';
import 'package:what_is_your_eta/presentation/core/dialog/user_info_dialog.dart';
import 'package:what_is_your_eta/presentation/core/widget/select_friend_dialog.dart';

class GroupView extends GetView<GroupViewModel> {
  const GroupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final group = controller.groupModel.value;
          if (group == null) return const Text('로딩 중...');

          return Text(group.title);
        }),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = controller.groupModel.value;
          if (data == null) {
            return const Center(child: Text('그룹 정보를 불러올 수 없습니다.'));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data.title, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  Get.dialog(
                    SelectFriendDialog(
                      friendList: controller.friendList, // ✅ 전체 친구 목록
                      selectedFriends: controller.selectedFriends,
                      toggleFriend: controller.toggleFriend,
                      disabledUids:
                          controller.memberList.map((u) => u.uid).toList(),
                      confirmText: '초대하기',
                      onConfirm: () {
                        controller.invite();
                        Get.back();
                      },
                    ),
                  );
                },
                child: const Text('친구 초대하기'),
              ),
              const SizedBox(height: 8),
              const Text('구성원'),
              Container(
                height: 100,
                color: Colors.indigo,
                child: groupMemberList(controller),
              ),

              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Get.to(
                    () => const LoungeInGroupView(),
                    arguments: controller.group.id,
                    binding: BindingsBuilder(() {
                      Get.put(
                        LoungeInGroupViewModel(
                          authRepository: Get.find<AuthRepository>(),
                          userRepository: Get.find<UserRepository>(),
                          groupRepository: Get.find<GroupRepository>(),
                          groupId: controller.group.id,
                        ),
                      );
                    }),
                  );
                },
                child: Container(
                  height: 50,
                  color: Colors.amber,
                  child: Center(child: const Text('속닥속닥 라운지')),
                ),
              ),
              const SizedBox(height: 20),
              const Text('약속'),
              const SizedBox(height: 12),

              SingleChildScrollView(
                child: Obx(() {
                  final promises = controller.promiseList;

                  if (promises.isEmpty) {
                    return const Text('약속이 없습니다.');
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: promises.length,
                    itemBuilder: (context, index) {
                      final promise = promises[index];
                      final isParticipant =
                          controller.promiseParticipationMap[promise.id] ??
                          false;

                      return GestureDetector(
                        onTap:
                            isParticipant
                                ? () {
                                  // 정상 참여중이면 이동
                                  Get.to(
                                    () => PromiseView(),
                                    binding: BindingsBuilder(() {
                                      Get.put(
                                        PromiseViewModel(
                                          promiseId: promise.id,
                                          promiseRepository:
                                              Get.find<PromiseRepository>(),
                                          authRepository:
                                              Get.find<AuthRepository>(),
                                          userRepository:
                                              Get.find<UserRepository>(),
                                        ),
                                      );
                                    }),
                                  );
                                }
                                : null, // 참여중이 아니면 onTap 없음
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                isParticipant
                                    ? Colors.white
                                    : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isParticipant ? Colors.blue : Colors.grey,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  promise.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color:
                                        isParticipant
                                            ? Colors.black
                                            : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                              if (!isParticipant)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    '미참여',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
              ElevatedButton(
                onPressed: () {
                  Get.to(
                    () => const CreatePromiseView(),
                    binding: BindingsBuilder(() {
                      Get.put(
                        CreatePromiseViewModel(
                          groupId: controller.group.id,
                          groupRepository: Get.find<GroupRepository>(),
                          userRepository: Get.find<UserRepository>(),
                          promiseRepository: Get.find<PromiseRepository>(),
                          fcmRepository: Get.find<FcmRepository>(),
                        ),
                      );
                    }),
                  );
                },

                child: Text('약속 추가하기'),
              ),
            ],
          );
        }),
      ),
    );
  }
}

Widget groupMemberList(GroupViewModel controller) {
  return Obx(() {
    final members = controller.memberList;
    if (members.isEmpty) {
      return const Text('구성원이 없습니다.');
    }

    final currentUid = controller.myUid.value;

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: members.length,
        itemBuilder: (context, index) {
          final user = members[index];
          final isSelf = user.uid == currentUid;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GestureDetector(
              onTap: () {
                if (controller.isOtherUser(user)) {
                  Get.dialog(
                    userInfoDialogView(
                      targetUser: user,
                      onChatPressed: () async {
                        final chatRoomId = await controller.createChatRoom(
                          user.uid,
                        );
                        if (controller.navigateToChat.value) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            controller.resetNavigateToChat();
                            Get.back(); // 다이얼로그 닫기
                            Get.to(
                              () => PrivateChatRoomView(),
                              binding: BindingsBuilder(() {
                                Get.put(
                                  PrivateChatRoomViewModel(
                                    chatRoomId: chatRoomId!,
                                    friendUid: user.uid,
                                    chatRepository: Get.find<ChatRepository>(),
                                    fcmRepository: Get.find<FcmRepository>(),
                                    userRepository: Get.find<UserRepository>(),
                                    myUid: controller.myUid.value,
                                  ),
                                );
                              }),
                            );
                          });
                        }
                      },
                    ),
                  );
                }
              },
              child: Opacity(
                opacity: isSelf ? 0.4 : 1.0, // 본인은 반투명하게
                child: Column(
                  children: [
                    CircleAvatar(backgroundImage: NetworkImage(user.photoUrl)),
                    Text(user.name, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  });
}
