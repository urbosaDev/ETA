import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String text;
  final DateTime sentAt;
  final List<String> checkedUserIds; // 체크한 유저들의 uid리스트
  final double? distanceFromMeetingPoint; // 약속장소와의 거리

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    required this.sentAt,
    this.checkedUserIds = const [],
    this.distanceFromMeetingPoint,
  });

  /// Firestore → Model
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      text: json['text'] as String,
      sentAt: (json['sentAt'] as Timestamp).toDate(),
      checkedUserIds: List<String>.from(json['checkedUserIds'] ?? []),
      distanceFromMeetingPoint:
          (json['distanceFromMeetingPoint'] as num?)?.toDouble(),
    );
  }

  /// Model → Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'text': text,
      'sentAt': Timestamp.fromDate(sentAt),
      'checkedUserIds': checkedUserIds,
      if (distanceFromMeetingPoint != null)
        'distanceFromMeetingPoint': distanceFromMeetingPoint,
    };
  }

  /// 일부 필드만 수정할 때
  MessageModel copyWith({
    String? id,
    String? senderId,
    String? text,
    DateTime? sentAt,
    List<String>? checkedUserIds,
    double? distanceFromMeetingPoint,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      sentAt: sentAt ?? this.sentAt,
      checkedUserIds: checkedUserIds ?? this.checkedUserIds,
      distanceFromMeetingPoint:
          distanceFromMeetingPoint ?? this.distanceFromMeetingPoint,
    );
  }
}
