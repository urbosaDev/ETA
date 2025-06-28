import 'package:cloud_firestore/cloud_firestore.dart';

// 그룹 모델 또한 최상위
// 컬렉션으로 chatRoom을 가진다.
// chatRoom은 message들을 가진 컬렉션,
// 채팅은 언제나 paging 사용
class GroupModel {
  final String id;
  final String title;
  final List<String> memberIds;
  final String chatRoomId;
  final List<String> promiseIds;
  final DateTime createdAt;
  final String createrId;

  const GroupModel({
    required this.id,
    required this.title,
    required this.memberIds,
    required this.chatRoomId,
    required this.promiseIds,
    required this.createdAt,
    required this.createrId,
  });

  /// Firestore → Model
  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'] as String,
      createrId: json['createrId'] as String,
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
      'createrId': createrId,
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
    String? createrId,
    String? title,
    List<String>? memberIds,
    String? chatRoomId,
    List<String>? promiseIds,
    DateTime? createdAt,
  }) {
    return GroupModel(
      id: id ?? this.id,
      createrId: createrId ?? this.createrId,
      title: title ?? this.title,
      memberIds: memberIds ?? this.memberIds,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      promiseIds: promiseIds ?? this.promiseIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
