import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise_log/promise_log_view_model.dart';

class PromiseLogView extends GetView<PromiseLogViewModel> {
  const PromiseLogView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('약속 기록')),
      body: Center(child: Text('약속 기록을 확인할 수 있는 화면입니다.')),
    );
  }
}
