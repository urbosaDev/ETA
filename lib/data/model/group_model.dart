import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  final String id;
  final String title;
  final List<String> memberIds;
  final String chatRoomId;
  final String? currentPromiseId;

  /// 완료된 약속 목록
  final List<String> endPromiseIds;

  final DateTime createdAt;
  final String createrId;

  const GroupModel({
    required this.id,
    required this.title,
    required this.memberIds,
    required this.chatRoomId,
    required this.currentPromiseId,
    required this.endPromiseIds,
    required this.createdAt,
    required this.createrId,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'] as String,
      createrId: json['createrId'] as String,
      title: json['title'] as String,
      memberIds: List<String>.from(json['memberIds'] ?? []),
      chatRoomId: json['chatRoomId'] as String,
      currentPromiseId: json['currentPromiseId'] as String?, // nullable
      endPromiseIds: List<String>.from(json['endPromiseIds'] ?? []),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createrId': createrId,
      'title': title,
      'memberIds': memberIds,
      'chatRoomId': chatRoomId,
      'currentPromiseId': currentPromiseId,
      'endPromiseIds': endPromiseIds,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  GroupModel copyWith({
    String? id,
    String? createrId,
    String? title,
    List<String>? memberIds,
    String? chatRoomId,
    String? currentPromiseId,
    List<String>? endPromiseIds,
    DateTime? createdAt,
  }) {
    return GroupModel(
      id: id ?? this.id,
      createrId: createrId ?? this.createrId,
      title: title ?? this.title,
      memberIds: memberIds ?? this.memberIds,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      currentPromiseId: currentPromiseId ?? this.currentPromiseId,
      endPromiseIds: endPromiseIds ?? this.endPromiseIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
