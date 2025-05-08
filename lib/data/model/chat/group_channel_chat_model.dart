import 'package:cloud_firestore/cloud_firestore.dart';

class GroupChannelChatModel {
  final String id;
  final List<String> memberIds;
  final List<String> messageIds;
  final DateTime createdAt;

  const GroupChannelChatModel({
    required this.id,
    required this.memberIds,
    required this.messageIds,
    required this.createdAt,
  });

  factory GroupChannelChatModel.fromJson(Map<String, dynamic> json) {
    return GroupChannelChatModel(
      id: json['id'] as String,
      memberIds: List<String>.from(json['memberIds'] ?? []),
      messageIds: List<String>.from(json['messageIds'] ?? []),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberIds': memberIds,
      'messageIds': messageIds,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  GroupChannelChatModel copyWith({
    String? id,
    List<String>? memberIds,
    List<String>? messageIds,
    DateTime? createdAt,
  }) {
    return GroupChannelChatModel(
      id: id ?? this.id,
      memberIds: memberIds ?? this.memberIds,
      messageIds: messageIds ?? this.messageIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
