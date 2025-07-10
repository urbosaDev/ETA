import 'package:cloud_firestore/cloud_firestore.dart';


class PrivateChatModel {
  final String id; // 챗 ID
  final List<String> participantIds; // 참여자 ID들
  final String? lastMessage; // 마지막 메시지 (미리보기용)
  final DateTime? lastMessageAt; // 마지막 메시지 시간 (정렬용)

  const PrivateChatModel({
    required this.id,
    required this.participantIds,
    this.lastMessage,
    this.lastMessageAt,
  });

  factory PrivateChatModel.fromJson(Map<String, dynamic> json) {
    return PrivateChatModel(
      id: json['id'] as String,
      participantIds: List<String>.from(json['participantIds'] ?? []),
      lastMessage: json['lastMessage'] as String?,
      lastMessageAt: (json['lastMessageAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participantIds': participantIds,
      if (lastMessage != null) 'lastMessage': lastMessage,
      if (lastMessageAt != null)
        'lastMessageAt': Timestamp.fromDate(lastMessageAt!),
    };
  }

  PrivateChatModel copyWith({
    String? id,
    List<String>? participantIds,
    String? lastMessage,
    DateTime? lastMessageAt,
  }) {
    return PrivateChatModel(
      id: id ?? this.id,
      participantIds: participantIds ?? this.participantIds,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
    );
  }
}
