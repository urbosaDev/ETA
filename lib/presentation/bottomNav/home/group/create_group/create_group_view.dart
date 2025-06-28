import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/create_group/create_group_view_model.dart';
import 'package:what_is_your_eta/presentation/core/widget/select_friend_dialog.dart';

class CreateGroupView extends GetView<CreateGroupViewModel> {
  const CreateGroupView({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController titleController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Create Group')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('제목을 설정하세염'),
          TextField(
            controller: titleController,
            onChanged: controller.onTitleChanged,
            decoration: const InputDecoration(
              labelText: 'Group Name',
              hintText: 'Enter group name',
            ),
          ),
          const SizedBox(height: 20),
          const Text('친구를 초대하세요'),
          GestureDetector(
            onTap: () {
              Get.dialog(
                SelectFriendDialog(
                  friendList: controller.friendList,
                  selectedFriends: controller.selectedFriends,
                  toggleFriend: controller.toggleFriend,
                  disabledUids: [], // ❗️CreateGroupView에서는 고정된 멤버 없음
                  confirmText: '선택 완료', // ✅ Confirm 버튼 텍스트
                  onConfirm: () => Get.back(), // ✅ 선택 완료 시 다이얼로그 닫기
                ),
              );
            },
            child: Container(
              height: 200,
              width: 400,
              color: Colors.amber,
              child: Center(
                child: Obx(() {
                  final selected = controller.selectedFriends;
                  if (selected.isEmpty) {
                    return const Text('이곳을 눌러 친구 초대하기');
                  } else {
                    return Wrap(
                      spacing: 8,
                      children:
                          selected
                              .map((f) => Chip(label: Text(f.name)))
                              .toList(),
                    );
                  }
                }),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Obx(
            () => Center(
              child: ElevatedButton(
                onPressed:
                    controller.isReadyToCreate && !controller.isCreating.value
                        ? () async {
                          final success = await controller.createGroup();
                          if (success) {
                            Get.offAllNamed('/main');
                            Get.snackbar('그룹 생성 완료', '그룹이 생성되었습니다.');
                          } else {
                            Get.snackbar('그룹 생성 실패', '다시 시도해주세요.');
                          }
                        }
                        : null,
                child:
                    controller.isCreating.value
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('그룹 만들기'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
