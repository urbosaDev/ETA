import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/group_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/group_view_model.dart';

class GroupView extends GetView<GroupViewModel> {
  final GroupModel group;
  const GroupView({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(group.title),
        Row(
          children: group.memberIds.map((memberId) => Text(memberId)).toList(),
        ),
        const SizedBox(height: 20),
        GestureDetector(onTap: () {}, child: Text('속닥속닥 라운지')),
        const SizedBox(height: 20),
        Text('약속'),
      ],
    );
  }
}
