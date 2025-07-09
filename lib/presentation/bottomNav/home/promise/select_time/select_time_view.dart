import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/promise/select_time/select_time_view_model.dart';

class SelectTimeView extends GetView<SelectTimeViewModel> {
  const SelectTimeView({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('시간 설정', style: textTheme.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '약속 시간을 정해요',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '날짜를 선택하세요',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => _buildPickerTile(
                      context,
                      textTheme,
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
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.dark().copyWith(
                                colorScheme: ColorScheme.dark(
                                  primary:
                                      Theme.of(context)
                                          .elevatedButtonTheme
                                          .style
                                          ?.backgroundColor
                                          ?.resolve({}) ??
                                      Colors.pinkAccent,
                                  onPrimary: Colors.white,
                                  surface: const Color(0xff1a1a1a),
                                  onSurface: Colors.white,
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white70,
                                  ),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          controller.setDate(picked);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '시간을 선택하세요',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Obx(
                          () => _buildPickerTile(
                            context,
                            textTheme,
                            label: '시',
                            value: '${controller.selectedHour.value}시',
                            onTap: () async {
                              final picked = await _showNumberPicker(
                                context,
                                textTheme,
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
                            textTheme,
                            label: '분',
                            value: '${controller.selectedMinute.value}분',
                            onTap: () async {
                              final picked = await _showNumberPicker(
                                context,
                                textTheme,
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
                  const Divider(color: Colors.green, thickness: 0.3),
                ],
              ),
            ),
            Expanded(
              flex: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '선택된 시간',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.greenAccent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    final date = controller.selectedDateTime;
                    return Text(
                      '${date.year}년 ${date.month}월 ${date.day}일\n${date.hour}시 ${date.minute}분',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    );
                  }),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.saveTime,
                      style: Theme.of(
                        context,
                      ).elevatedButtonTheme.style?.copyWith(
                        backgroundColor: MaterialStateProperty.all(
                          Colors.green,
                        ),
                      ),
                      child: Text(
                        '저장하기',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerTile(
    BuildContext context,
    TextTheme textTheme, {
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xff1a1a1a),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(value, style: textTheme.bodyMedium),
            Icon(Icons.arrow_drop_down, color: Colors.white70),
          ],
        ),
      ),
    );
  }

  Future<int?> _showNumberPicker(
    BuildContext context,
    TextTheme textTheme,
    int min,
    int max,
    int current,
  ) async {
    final isMinutePicker = (min == 0 && max == 59);

    final List<int> values =
        isMinutePicker
            ? [0, 10, 20, 30, 40, 50]
            : List.generate(max - min + 1, (index) => min + index);

    return await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (_) => Container(
            height: 300,
            decoration: BoxDecoration(
              color: const Color(0xff1a1a1a),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              border: Border.all(color: Colors.white12, width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    isMinutePicker ? '분 선택' : '시 선택',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(color: Colors.white12, thickness: 0.2),
                Expanded(
                  child: ListView.builder(
                    itemExtent: 48,
                    itemCount: values.length,
                    itemBuilder: (context, index) {
                      final value = values[index];
                      final isSelected = (value == current);
                      return ListTile(
                        title: Center(
                          child: Text(
                            '$value',
                            style: textTheme.bodyMedium?.copyWith(
                              color:
                                  isSelected
                                      ? Theme.of(context)
                                              .elevatedButtonTheme
                                              .style
                                              ?.backgroundColor
                                              ?.resolve({}) ??
                                          Colors.pinkAccent
                                      : Colors.white,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                        ),
                        onTap: () => Navigator.of(context).pop(value),
                        selected: isSelected,
                        selectedTileColor: Colors.white.withOpacity(0.05),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
