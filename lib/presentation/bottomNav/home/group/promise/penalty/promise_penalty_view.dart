import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/penalty/promise_penalty_view_model.dart';

class PromisePenaltyView extends GetView<PromisePenaltyViewModel> {
  const PromisePenaltyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('벌칙')),
      body: Center(child: Text('벌칙 기능은 아직 개발 중입니다.')),
    );
  }
}
