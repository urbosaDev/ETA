import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/promise/create_promise/create_promise_view_model.dart';

class CreatePromiseView extends GetView<CreatePromiseViewModel> {
  const CreatePromiseView({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: const Text('약속 생성')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('약속 이름을 정해요'),
                const SizedBox(height: 8),
                buildTextField(
                  controller: nameController,
                  label: '약속 이름을 입력해주세요',
                  onChanged: (value) => controller.promiseName.value = value,
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('구성원을 모집해요'),
                    IconButton(
                      onPressed: () {
                        final group = controller.groupModel.value;
                        if (group != null) {
                          controller.fetchMembers(group.memberIds);
                        }
                      },
                      icon: const Text('↻'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Obx(() {
                  if (controller.isMemberFetchLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return SizedBox(
                    height: 200,
                    child: buildAddMemberField(controller.memberList),
                  );
                }),
                const SizedBox(height: 24),

                const Text('약속 위치를 정해봐요'),
                const SizedBox(height: 8),
                buildSelectLocationField(),

                const SizedBox(height: 24),

                const Text('약속 시간을 정해요'),
                const SizedBox(height: 8),
                buildSelectTimeField(),

                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    // TODO: 생성 조건 확인 후 구현
                  },
                  child: const Text('약속 생성하기'),
                ),
              ],
            ),
          ),
        ),

        // 로딩 오버레이
        Obx(() {
          if (controller.isLoading.value) {
            return const ColoredBox(
              color: Colors.black38,
              child: Center(child: CircularProgressIndicator()),
            );
          } else {
            return const SizedBox.shrink();
          }
        }),
      ],
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required Function(String) onChanged,
  }) {
    return TextField(
      controller: controller,
      onChanged: (value) {
        print('입력된 약속 이름: $value');
      },
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget buildAddMemberField(List<UserModel> memberList) {
    return ListView.builder(
      itemCount: memberList.length,
      itemBuilder: (context, index) {
        final member = memberList[index];

        return Obx(() {
          final isSelected = controller.selectedMembers.any(
            (e) => e.uid == member.uid,
          );
          return GestureDetector(
            onTap: () => controller.toggleMember(member),
            child: Container(
              color:
                  isSelected ? Colors.lightBlue.shade100 : Colors.transparent,
              child: ListTile(
                title: Text(member.name),
                subtitle: Text(member.uniqueId),
                trailing: Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? Colors.blue : Colors.grey,
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Widget buildSelectLocationField() {
    return GestureDetector(
      onTap: () {
        // TODO: 위치 선택 기능 구현 예정
      },
      child: Container(
        height: 100,
        width: double.infinity,
        color: Colors.amber,
        child: const Center(child: Text('약속 위치를 선택하세요')),
      ),
    );
  }

  Widget buildSelectTimeField() {
    return GestureDetector(
      onTap: () {
        // TODO: 시간 선택 기능 구현 예정
      },
      child: Container(
        height: 100,
        width: double.infinity,
        color: Colors.amber,
        child: const Center(child: Text('약속 시간을 선택하세요')),
      ),
    );
  }
}
