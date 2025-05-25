import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/group_model.dart';
import 'package:what_is_your_eta/data/repository/group_repository.dart';

import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/group_view_model.dart';

class GroupView extends StatelessWidget {
  final GroupModel group;
  const GroupView({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      GroupViewModel(
        groupRepository: Get.find<GroupRepository>(),
        group: group,
      ),
      tag: group.id,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ 그룹 제목만 리액티브 처리
        Obx(() {
          final data = controller.groupModel.value;
          if (data == null) return const CircularProgressIndicator();
          return Text(data.title);
        }),
        Text('친구 초대하기'),
        Text('구성원'),
        Container(height: 200, color: Colors.indigo),

        const SizedBox(height: 20),
        GestureDetector(onTap: () {}, child: const Text('속닥속닥 라운지')),
        const SizedBox(height: 20),
        const Text('약속'),
        const SizedBox(height: 20),

        // ✅ 약속 리스트도 리액티브 처리
        Obx(() {
          final data = controller.groupModel.value;
          if (data == null) return const SizedBox();

          if (data.promiseIds.isEmpty) {
            return const Text('약속이 없습니다.');
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.promiseIds.length,
            itemBuilder: (context, index) {
              final promiseId = data.promiseIds[index];
              return GestureDetector(
                onTap: () {
                  Get.toNamed('/promise/$promiseId');
                },
                child: Text('약속 $promiseId'),
              );
            },
          );
        }),
      ],
    );
  }
}
