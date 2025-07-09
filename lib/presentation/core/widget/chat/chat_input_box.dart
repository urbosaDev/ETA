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
      color: const Color(0xFF111111),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(height: 1, color: const Color(0xFFA8216B).withOpacity(0.5)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      keyboardAppearance: Brightness.dark,
                      controller: controller,
                      style: const TextStyle(color: Colors.white),

                      decoration: InputDecoration(
                        hintText: '@메세지를 입력하세요',
                        hintStyle: TextStyle(
                          color: const Color(0xFFA8216B).withOpacity(0.5),
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),

                        filled: true,
                        fillColor: const Color(0xFF222222),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(
                            color: Color(0xFFA8216B),
                            width: 0.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(
                            color: Color(0xFFA8216B),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(
                            color: Color(0xFFA8216B),
                            width: 1,
                          ),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.send),
                          color: const Color(0xFFA8216B).withOpacity(0.5),
                          onPressed: () {
                            final msg = controller.text.trim();
                            if (msg.isNotEmpty) {
                              onSend(msg);
                            }
                          },
                        ),
                      ),
                    ),
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
