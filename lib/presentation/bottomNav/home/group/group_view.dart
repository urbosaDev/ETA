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
  final String groupTag;
  const GroupView({super.key, required this.groupTag});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GroupViewModel>(tag: groupTag);
    return SafeArea(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.title, style: const TextStyle(fontSize: 20)),
                    Text('그룹장 : ${controller.leaderModel.value?.name}'),
                  ],
                ),
                Align(
                  alignment: Alignment.centerRight,

                  child: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        controller.deleteGroup();
                      } else if (value == 'leave') {
                        controller.leaveGroup();
                      }
                    },
                    itemBuilder:
                        (context) => [
                          if (controller.isMyGroup) ...[
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('그룹 삭제'),
                            ),
                          ] else ...[
                            const PopupMenuItem(
                              value: 'leave',
                              child: Text('그룹 나가기'),
                            ),
                          ],
                        ],
                    icon: const Icon(Icons.more_vert),
                  ),
                ),
              ],
            ),
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
            const Text('현재 진행중인 약속'),
            const SizedBox(height: 12),

            Obx(() {
              final promise = controller.currentPromise.value;

              if (promise != null) {
                return GestureDetector(
                  onTap:
                      controller.isParticipating.value
                          ? () {
                            // 정상 참여중이면 이동
                            Get.to(
                              () => PromiseView(),
                              binding: BindingsBuilder(() {
                                Get.put(
                                  PromiseViewModel(promiseId: promise.id),
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
                          controller.isParticipating.value
                              ? Colors.white
                              : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            controller.isParticipating.value
                                ? Colors.blue
                                : Colors.grey,
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
                                  controller.isParticipating.value
                                      ? Colors.black
                                      : Colors.grey.shade600,
                            ),
                          ),
                        ),
                        if (!controller.isParticipating.value)
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
              } else {
                return const Text('약속이 없습니다.');
              }
            }),

            Row(
              children: [
                // 왼쪽: 약속 추가하러 가기
                Flexible(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          '약속 추가하러 가기',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap:
                            controller.isPromiseExisted.value
                                ? null
                                : () {
                                  Get.to(
                                    () => const CreatePromiseView(),
                                    binding: BindingsBuilder(() {
                                      Get.put(
                                        CreatePromiseViewModel(
                                          groupId: controller.group.id,
                                          groupRepository:
                                              Get.find<GroupRepository>(),
                                          userRepository:
                                              Get.find<UserRepository>(),
                                          promiseRepository:
                                              Get.find<PromiseRepository>(),
                                          fcmRepository:
                                              Get.find<FcmRepository>(),
                                        ),
                                      );
                                    }),
                                  );
                                },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          height: 150,
                          decoration: BoxDecoration(
                            color:
                                controller.isPromiseExisted.value
                                    ? Colors.grey.shade300
                                    : Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              controller.isPromiseExisted.value
                                  ? '현재 진행중인 약속을 마감해야\n새로운 약속을 추가할 수 있어요'
                                  : '약속을 추가하러 가기',
                              style: TextStyle(
                                color:
                                    controller.isPromiseExisted.value
                                        ? Colors.grey.shade700
                                        : Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // 오른쪽: 예전 약속들이 궁금하다면
                Flexible(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          '약속 log보기',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // TODO: 예전 약속 리스트로 이동
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.green.shade400,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              '지난 약속 목록 보기',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Column(
              children: [
                ElevatedButton(
                  onPressed:
                      controller.isMyGroup &&
                              controller.currentPromise.value != null
                          ? () {
                            Get.dialog(
                              _buildEndPromiseDialog(
                                onConfirm: () {
                                  controller.endPromise();
                                  Get.back(); // 다이얼로그 닫기
                                },
                              ),
                            );
                          }
                          : null, // 그룹장이 아니면 버튼 비활성화
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        controller.isMyGroup
                            ? Colors.blue
                            : Colors.grey.shade400,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('현재 약속 마감하기'),
                ),
                const SizedBox(height: 4),
                const Text('약속 마감은 그룹장만 진행할 수 있어요.'),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _buildEndPromiseDialog({required VoidCallback onConfirm}) {
    return AlertDialog(
      title: const Text('약속 마감'),
      content: const Text(
        '현재 진행중인 약속을 마감하시겠어요? \n 진행되지 않은 약속은 삭제됩니다. \n진행된 약속은 기록으로 볼 수 있어요',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back(); // 아니오: 그냥 닫기
          },
          child: const Text('아니오'),
        ),
        ElevatedButton(onPressed: onConfirm, child: const Text('네')),
      ],
    );
  }
}

Widget groupMemberList(GroupViewModel controller) {
  return Obx(() {
    final members = controller.memberList;
    if (members.isEmpty) {
      return const Text('구성원이 없습니다.');
    }

    final currentUid = controller.currentUser;

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
                                    myUid: controller.currentUser!,
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
