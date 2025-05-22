import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/create_group/create_group_view_model.dart';

class CreateGroupView extends GetView<CreateGroupViewModel> {
  const CreateGroupView({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text('Create Group')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: const [Text('제목을 설정하세염')]),
          TextField(
            controller: titleController,
            onChanged: controller.onTitleChanged,
            decoration: const InputDecoration(
              labelText: 'Group Name',
              hintText: 'Enter group name',
            ),
          ),
          const SizedBox(height: 20),
          Row(children: const [Text('친구를 초대하세요')]),
          GestureDetector(
            onTap: () {
              Get.dialog(SelectFriendDialog(controller: controller));
            },
            child: Container(
              height: 200,
              width: 400,
              color: Colors.amber,
              child: Center(
                child: Obx(() {
                  if (controller.selectedFriends.isEmpty) {
                    return const Text('이곳을 눌러 친구 초대하기');
                  } else {
                    return Wrap(
                      spacing: 8,
                      children:
                          controller.selectedFriends
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
                    controller.isReadyToCreate
                        ? () async {
                          await controller.createGroup();
                          if (controller.isGroupCreated.value) {
                            Get.offAllNamed('/main');
                            Get.snackbar('그룹 생성 완료', '그룹이 생성되었습니다.');
                          } else {
                            Get.snackbar('그룹 생성 실패', '그룹 생성에 실패했습니다.');
                          }
                        }
                        : null,
                child: const Text('그룹 만들기'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SelectFriendDialog extends StatelessWidget {
  final CreateGroupViewModel controller;

  const SelectFriendDialog({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 500,
        width: 400,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '내 친구 목록에서 추가하기',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('선택된 친구들'),
            const SizedBox(height: 8),

            Obx(() {
              final selected = controller.selectedFriends;
              return Container(
                height: 80,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.lime.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    selected.isEmpty
                        ? const Center(child: Text('아직 선택된 친구 없음'))
                        : ListView(
                          scrollDirection: Axis.horizontal,
                          children:
                              selected
                                  .map(
                                    (f) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.lime.shade400,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(f.name),
                                    ),
                                  )
                                  .toList(),
                        ),
              );
            }),

            const SizedBox(height: 12),

            Expanded(
              child: Obx(() {
                final selectedUids =
                    controller.selectedFriends.map((f) => f.uid).toSet();
                final friends = controller.friendList;

                return ListView.builder(
                  itemCount: friends.length,
                  itemBuilder: (context, index) {
                    final friend = friends[index];
                    final isSelected = selectedUids.contains(friend.uid);

                    return ListTile(
                      title: Text(friend.name),
                      subtitle: Text(friend.uniqueId),
                      trailing: Icon(
                        isSelected ? Icons.check : Icons.add,
                        color: isSelected ? Colors.green : null,
                      ),
                      onTap: () => controller.toggleFriend(friend),
                    );
                  },
                );
              }),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(), // result 없이 닫기만
                child: const Text('선택 완료'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
