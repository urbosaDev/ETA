import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'select_time_view_model.dart';

class SelectTimeView extends GetView<SelectTimeViewModel> {
  const SelectTimeView({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text('시간 설정')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('시간 정하기'),
            const SizedBox(height: 16),

            const Text('날짜를 선택하세요'),
            const SizedBox(height: 8),
            Obx(
              () => _buildPickerTile(
                context,
                label: '날짜',
                value:
                    '${controller.selectedYear.value}년 ${controller.selectedMonth.value}월 ${controller.selectedDay.value}일',
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate:
                        controller.selectedDateTime.isBefore(now)
                            ? now
                            : controller.selectedDateTime,
                    firstDate: now,
                    lastDate: DateTime(now.year + 3),
                  );
                  if (picked != null) {
                    controller.setDate(picked);
                  }
                },
              ),
            ),

            const SizedBox(height: 16),
            const Text('시간을 선택하세요'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Obx(
                    () => _buildPickerTile(
                      context,
                      label: '시',
                      value: '${controller.selectedHour.value}시',
                      onTap: () async {
                        final picked = await _showNumberPicker(
                          context,
                          0,
                          23,
                          controller.selectedHour.value,
                        );
                        if (picked != null) controller.setHour(picked);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Obx(
                    () => _buildPickerTile(
                      context,
                      label: '분',
                      value: '${controller.selectedMinute.value}분',
                      onTap: () async {
                        final picked = await _showNumberPicker(
                          context,
                          0,
                          59,
                          controller.selectedMinute.value,
                        );
                        if (picked != null) controller.setMinute(picked);
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
            Obx(() {
              final date = controller.selectedDateTime;
              return Text(
                '${date.year}년 ${date.month}월 ${date.day}일\n${date.hour}시 ${date.minute}분',
                style: const TextStyle(fontSize: 18),
              );
            }),

            const Spacer(),
            ElevatedButton(
              onPressed: controller.saveTime,
              child: const Center(child: Text('저장하기')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerTile(
    BuildContext context, {
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(value, style: const TextStyle(fontSize: 16)),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Future<int?> _showNumberPicker(
    BuildContext context,
    int min,
    int max,
    int current,
  ) async {
    return await showModalBottomSheet<int>(
      context: context,
      builder:
          (_) => SizedBox(
            height: 300,
            child: ListView.builder(
              itemExtent: 48,
              itemCount: max - min + 1,
              itemBuilder: (context, index) {
                final value = min + index;
                return ListTile(
                  title: Center(child: Text('$value')),
                  onTap: () => Navigator.of(context).pop(value),
                );
              },
            ),
          ),
    );
  }
}
