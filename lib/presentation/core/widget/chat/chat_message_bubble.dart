import 'package:flutter/material.dart';

class ChatMessageBubble extends StatelessWidget {
  final bool isMe;
  final bool isSystem;
  final String message;
  final String? senderName;
  final String? senderPhotoUrl;

  const ChatMessageBubble({
    super.key,
    required this.isMe,
    required this.isSystem,
    required this.message,
    this.senderName,
    this.senderPhotoUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (isSystem) {
      // 📌 시스템 메시지 스타일
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade400,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    // 🧍 일반 유저 메시지 스타일
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe && senderName != null && senderPhotoUrl != null)
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundImage: NetworkImage(senderPhotoUrl!),
                ),
                const SizedBox(width: 4),
                Text(senderName!, style: const TextStyle(fontSize: 12)),
              ],
            ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isMe ? Colors.blueAccent : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message,
              style: TextStyle(color: isMe ? Colors.white : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
