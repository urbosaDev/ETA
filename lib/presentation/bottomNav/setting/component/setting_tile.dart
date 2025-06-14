import 'package:flutter/material.dart';

class SettingTile extends StatelessWidget {
  final String title;
  final String? value;
  final VoidCallback onTap;

  const SettingTile({
    super.key,
    required this.title,
    required this.onTap,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing:
          value != null
              ? Text(value!, style: TextStyle(color: Colors.grey[500]))
              : const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
