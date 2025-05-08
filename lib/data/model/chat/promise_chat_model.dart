import 'package:cloud_firestore/cloud_firestore.dart';

class PromiseChatModel {
  final String id;
  final String title;
  final List<String> participantIds;
  final GeoPoint location;
  final DateTime scheduledAt;
  final List<String> messageIds;
  final DateTime createdAt;

  const PromiseChatModel({
    required this.id,
    required this.title,
    required this.participantIds,
    required this.location,
    required this.scheduledAt,
    required this.messageIds,
    required this.createdAt,
  });

  /// Firestore → Model
  factory PromiseChatModel.fromJson(Map<String, dynamic> json) {
    return PromiseChatModel(
      id: json['id'] as String,
      title: json['title'] as String,
      participantIds: List<String>.from(json['participantIds'] ?? []),
      location: json['location'] as GeoPoint,
      scheduledAt: (json['scheduledAt'] as Timestamp).toDate(),
      messageIds: List<String>.from(json['messageIds'] ?? []),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Model → Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'participantIds': participantIds,
      'location': location,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'messageIds': messageIds,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// 일부 필드만 수정하고 싶을 때 사용
  PromiseChatModel copyWith({
    String? id,
    String? title,
    List<String>? participantIds,
    GeoPoint? location,
    DateTime? scheduledAt,
    List<String>? messageIds,
    DateTime? createdAt,
  }) {
    return PromiseChatModel(
      id: id ?? this.id,
      title: title ?? this.title,
      participantIds: participantIds ?? this.participantIds,
      location: location ?? this.location,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      messageIds: messageIds ?? this.messageIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
