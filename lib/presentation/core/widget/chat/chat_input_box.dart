import 'package:flutter/material.dart';

class ChatInputBox extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String) onSend;

  const ChatInputBox({
    super.key,
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                onSubmitted: (value) {
                  final trimmed = value.trim();
                  if (trimmed.isNotEmpty) {
                    onSend(trimmed);
                  }
                },
                decoration: const InputDecoration(
                  hintText: '메세지를 입력하세요',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                final msg = controller.text.trim();
                if (msg.isNotEmpty) {
                  onSend(msg);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
