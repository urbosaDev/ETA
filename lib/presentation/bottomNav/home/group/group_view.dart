import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/group_model.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';

import 'package:what_is_your_eta/data/repository/group_repository.dart';
import 'package:what_is_your_eta/data/repository/promise_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';

import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/group_view_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/lounge_in_group/lounge_in_group_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/lounge_in_group/lounge_in_group_view_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/promise_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/promise_view_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/promise/create_promise/create_promise_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/promise/create_promise/create_promise_view_model.dart';
import 'package:what_is_your_eta/presentation/core/widget/select_friend_dialog.dart';

class GroupView extends StatelessWidget {
  final GroupModel group;
  const GroupView({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    Get.delete<GroupViewModel>();

    // 새 ViewModel 주입 (tag 없이)
    final controller = Get.put(
      GroupViewModel(
        promiseRepository: Get.find(),
        groupRepository: Get.find(),
        userRepository: Get.find(),
        authRepository: Get.find(),
        group: group,
      ),
    );

    // ever<String?>(controller.snackbarMessage, (msg) {
    //   if (msg != null) {
    //     Get.snackbar('알림', msg);
    //   }
    // });

    return Obx(() {
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
              Get.delete<LoungeInGroupViewModel>(force: true);
              Get.to(
                () => const LoungeInGroupView(),
                arguments: group.id,
                binding: BindingsBuilder(() {
                  Get.put(
                    LoungeInGroupViewModel(
                      authRepository: Get.find<AuthRepository>(),
                      userRepository: Get.find<UserRepository>(),
                      groupRepository: Get.find<GroupRepository>(),
                      groupId: group.id,
                    ),
                    // tag: group.id,
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

          Obx(() {
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
                return GestureDetector(
                  onTap: () {
                    Get.to(
                      () => PromiseView(),
                      binding: BindingsBuilder(() {
                        Get.put(
                          PromiseViewModel(
                            promiseId: promise.id,
                            promiseRepository: Get.find<PromiseRepository>(),
                            authRepository: Get.find<AuthRepository>(),
                            userRepository: Get.find<UserRepository>(),
                          ),
                        );
                      }),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 4,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              promise.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              promise.time.toLocal().toString(),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    promise.location.address,
                                    style: const TextStyle(fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  promise.location.placeName,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
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
                    ),
                  );
                }),
              );
            },

            child: Text('약속 추가하기'),
          ),
        ],
      );
    });
  }

  Widget groupMemberList(GroupViewModel controller) {
    return Obx(() {
      final members = controller.memberList;
      if (members.isEmpty) {
        return const Text('구성원이 없습니다.');
      }

      return SizedBox(
        height: 80,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: members.length,
          itemBuilder: (context, index) {
            final user = members[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  CircleAvatar(backgroundImage: NetworkImage(user.photoUrl)),
                  Text(user.name, style: const TextStyle(fontSize: 12)),
                ],
              ),
            );
          },
        ),
      );
    });
  }
}
