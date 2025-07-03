import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:what_is_your_eta/presentation/report/report_view_model.dart';

class ReportView extends GetView<ReportViewModel> {
  const ReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('무엇을 신고하려고 하시나요?')),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '이 사용자의 프로필에서 신고할 항목을 선택하세요.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: Obx(() {
                return ListView(
                  children:
                      controller.reportReasonLabels.entries.map((entry) {
                        return CheckboxListTile(
                          title: Text(entry.value),
                          value: controller.isSelected(entry.key),
                          onChanged: (_) => controller.toggleReason(entry.key),
                        );
                      }).toList(),
                );
              }),
            ),

            Obx(() {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed:
                      controller.canSubmit ? controller.submitReport : null,
                  child: const Text('신고하기'),
                ),
              );
            }),

            Obx(() {
              if (controller.success.value) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Get.back();
                  Get.snackbar(
                    '신고 완료',
                    '신고가 성공적으로 접수되었습니다.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  controller.success.value = false; // 초기화
                });
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }
}
