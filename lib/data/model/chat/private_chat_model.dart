import 'package:cloud_firestore/cloud_firestore.dart';

class PrivateChatModel {
  final String id;
  final List<String> participantIds;
  final List<String> messageIds;
  final DateTime createdAt;

  const PrivateChatModel({
    required this.id,
    required this.participantIds,
    required this.messageIds,
    required this.createdAt,
  });

  factory PrivateChatModel.fromJson(Map<String, dynamic> json) {
    return PrivateChatModel(
      id: json['id'] as String,
      participantIds: List<String>.from(json['participantIds'] ?? []),
      messageIds: List<String>.from(json['messageIds'] ?? []),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participantIds': participantIds,
      'messageIds': messageIds,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  PrivateChatModel copyWith({
    String? id,
    List<String>? participantIds,
    List<String>? messageIds,
    DateTime? createdAt,
  }) {
    return PrivateChatModel(
      id: id ?? this.id,
      participantIds: participantIds ?? this.participantIds,
      messageIds: messageIds ?? this.messageIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
