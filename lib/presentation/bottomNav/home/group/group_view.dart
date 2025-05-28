import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/group_model.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';

import 'package:what_is_your_eta/data/repository/group_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';

import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/group_view_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/lounge_in_group/lounge_in_group_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/lounge_in_group/lounge_in_group_view_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/promise/create_promise/create_promise_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/promise/create_promise/create_promise_view_model.dart';
import 'package:what_is_your_eta/presentation/core/widget/select_friend_dialog.dart';

class GroupView extends StatelessWidget {
  final GroupModel group;
  const GroupView({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      GroupViewModel(
        groupRepository: Get.find<GroupRepository>(),
        userRepository: Get.find<UserRepository>(),
        authRepository: Get.find<AuthRepository>(),
        group: group,
      ),
      tag: group.id,
      permanent: false,
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
                    tag: group.id,
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
          const SizedBox(height: 20),

          data.promiseIds.isEmpty
              ? const Text('약속이 없습니다.')
              : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: data.promiseIds.length,
                itemBuilder: (context, index) {
                  final promiseId = data.promiseIds[index];
                  return GestureDetector(
                    onTap: () {
                      Get.toNamed('/promise/$promiseId');
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text('약속 $promiseId'),
                    ),
                  );
                },
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
