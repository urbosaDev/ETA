import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  final String id;
  final String title;
  final List<String> memberIds;
  final String chatRoomId;
  final List<String> promiseIds;
  final DateTime createdAt;

  const GroupModel({
    required this.id,
    required this.title,
    required this.memberIds,
    required this.chatRoomId,
    required this.promiseIds,
    required this.createdAt,
  });

  /// Firestore → Model
  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'] as String,
      title: json['title'] as String,
      memberIds: List<String>.from(json['memberIds'] ?? []),
      chatRoomId: json['chatRoomId'] as String,
      promiseIds: List<String>.from(json['promiseIds'] ?? []),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Model → Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'memberIds': memberIds,
      'chatRoomId': chatRoomId,
      'promiseIds': promiseIds,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// 상태 업데이트용
  GroupModel copyWith({
    String? id,
    String? title,
    List<String>? memberIds,
    String? chatRoomId,
    List<String>? promiseIds,
    DateTime? createdAt,
  }) {
    return GroupModel(
      id: id ?? this.id,
      title: title ?? this.title,
      memberIds: memberIds ?? this.memberIds,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      promiseIds: promiseIds ?? this.promiseIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
