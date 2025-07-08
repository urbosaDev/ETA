import 'package:flutter/material.dart';

class SettingTile extends StatelessWidget {
  final String title;
  final String? value;
  final VoidCallback onTap;

  const SettingTile({
    super.key,
    required this.title,
    this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      // 탭 효과를 위해 InkWell 사용
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ), // 패딩 조정
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: textTheme.bodySmall),
            if (value != null)
              Flexible(
                child: Text(
                  value!,
                  textAlign: TextAlign.end,
                  style: textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
