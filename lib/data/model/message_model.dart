import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  // final String id;
  final String senderId;
  final String text;
  final DateTime sentAt;
  final List<String> readBy;

  const MessageModel({
    // required this.id,
    required this.senderId,
    required this.text,
    required this.sentAt,
    this.readBy = const [],
  });

  /// Firestore → Model
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      // id: json['id'] as String,
      senderId: json['senderId'] as String,
      text: json['text'] as String,
      sentAt: (json['sentAt'] as Timestamp).toDate(),
      readBy: List<String>.from(json['readBy'] ?? []),
    );
  }

  /// Model → Firestore
  Map<String, dynamic> toJson() {
    return {
      // 'id': id,
      'senderId': senderId,
      'text': text,
      'sentAt': Timestamp.fromDate(sentAt),
      'readBy': readBy,
    };
  }

  /// 일부 필드만 수정할 때
  MessageModel copyWith({
    // String? id,
    String? senderId,
    String? text,
    DateTime? sentAt,
    List<String>? readBy,
  }) {
    return MessageModel(
      // id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      sentAt: sentAt ?? this.sentAt,
      readBy: readBy ?? this.readBy,
    );
  }
}
