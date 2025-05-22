import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/group_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/group_view_model.dart';

class GroupView extends GetView<GroupViewModel> {
  final GroupModel group;
  const GroupView({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(group.title)),
      body: const Center(child: Text('Group View')),
    );
  }
}
