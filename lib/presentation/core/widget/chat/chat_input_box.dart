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
    return Container(
      color: const Color(0xFF111111), // 디코 배경색
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 구분선
          Container(height: 1, color: Color(0xFFA8216B).withOpacity(0.5)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  // 텍스트 입력창
                  Expanded(
                    child: TextField(
                      controller: controller,
                      style: const TextStyle(
                        color: Colors.white, // 입력 텍스트 색
                      ),
                      decoration: InputDecoration(
                        hintText: '메세지를 입력하세요',
                        hintStyle: TextStyle(
                          color: Color(
                            0xFFA8216B,
                          ).withOpacity(0.5), // placeholder 색상
                        ),
                        filled: true,
                        fillColor: const Color(0xFF222222),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 전송 버튼
                  IconButton(
                    icon: const Icon(Icons.send),
                    color: const Color(0xFFA8216B).withOpacity(0.5), // 버튼 색상
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
          ),
        ],
      ),
    );
  }
}
