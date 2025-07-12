import 'package:flutter/material.dart';

class SettingTile extends StatelessWidget {
  final String title;
  final String? value;
  final VoidCallback? onTap;
  final Widget? valueWidget;

  const SettingTile({
    super.key,
    required this.title,
    this.value,
    this.onTap,
    this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(title, style: textTheme.bodySmall)),

            if (value != null)
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  height: 20,
                  child: Text(
                    value!,
                    textAlign: TextAlign.end,
                    style: textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ),
              ),

            if (value == null && valueWidget != null)
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  height: 20,
                  child: Transform.scale(
                    scale: 0.7,
                    alignment: Alignment.centerRight,
                    child: valueWidget!,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
