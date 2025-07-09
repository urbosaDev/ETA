import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise_log/component/promise_log_tile.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise_log/promise_log_view_model.dart';
import 'package:what_is_your_eta/presentation/core/loading/common_loading_lottie.dart';

class PromiseLogView extends GetView<PromiseLogViewModel> {
  const PromiseLogView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('약속 기록')),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CommonLoadingLottie());
          }

          if (controller.endPromises.isEmpty) {
            return const Center(child: Text('약속 기록이 없습니다.'));
          }

          return ListView.builder(
            itemCount: controller.endPromises.length,
            itemBuilder: (context, index) {
              final promise = controller.endPromises[index];
              return PromiseLogTile(promise: promise);
            },
          );
        }),
      ),
    );
  }
}
