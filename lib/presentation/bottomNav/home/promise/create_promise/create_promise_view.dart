import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/promise/create_promise/create_promise_view_model.dart';

class CreatePromiseView extends GetView<CreatePromiseViewModel> {
  const CreatePromiseView({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController textController = TextEditingController();
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: const Text('약속 생성')),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('약속 이름을 정해요'),
                buildTextField(textController, '약속 이름을 입력해주세요'),
                const Text('구성원을 모집해요'),
                SizedBox(
                  height: 200,
                  child: Obx(() {
                    return buildAddMemberField(controller.memberList);
                  }),
                ),
                const Text('약속 위치를 정해봐요'),
                buildSelectLocationField(),
                const Text('약속 시간을 정해요'),
                buildSelectTimeField(),
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
            return const SizedBox.shrink(); // 아무것도 안 보이게
          }
        }),
      ],
    );
  }

  Widget buildTextField(textController, String label) {
    return TextField(decoration: InputDecoration(labelText: label));
  }

  Widget buildAddMemberField(List<UserModel> memberList) {
    return ListView.builder(
      itemCount: memberList.length,
      itemBuilder: (context, index) {
        final member = memberList[index];
        return ListTile(
          title: Text(member.name),
          subtitle: Text(member.uniqueId),
          trailing: IconButton(
            icon: const Icon(Icons.remove_circle),
            onPressed: () {},
          ),
        );
      },
    );
  }

  Widget buildSelectLocationField() {
    return GestureDetector(
      onTap: () {},
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
      onTap: () {},
      child: Container(
        height: 100,
        width: double.infinity,
        color: Colors.amber,
        child: const Center(child: Text('약속 시간을 선택하세요')),
      ),
    );
  }
}
