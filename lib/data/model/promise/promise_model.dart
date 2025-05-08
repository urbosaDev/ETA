import 'package:cloud_firestore/cloud_firestore.dart';

class PromiseModel {
  final String id;
  final String title;
  final List<String> memberIds;
  final GeoPoint location;
  final String address;
  final DateTime scheduledAt;
  final String chatRoomId;
  final bool isOngoing; // 진행 중 여부

  const PromiseModel({
    required this.id,
    required this.title,
    required this.memberIds,
    required this.location,
    required this.address,
    required this.scheduledAt,
    required this.chatRoomId,
    this.isOngoing = false, // 기본값 false
  });

  /// Firestore → Model
  factory PromiseModel.fromJson(Map<String, dynamic> json) {
    return PromiseModel(
      id: json['id'] as String,
      title: json['title'] as String,
      memberIds: List<String>.from(json['memberIds'] ?? []),
      location: json['location'] as GeoPoint,
      address: json['address'] as String,
      scheduledAt: (json['scheduledAt'] as Timestamp).toDate(),
      chatRoomId: json['chatRoomId'] as String,
      isOngoing: json['isOngoing'] as bool? ?? false,
    );
  }

  /// Model → Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'memberIds': memberIds,
      'location': location,
      'address': address,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'chatRoomId': chatRoomId,
      'isOngoing': isOngoing,
    };
  }

  /// 상태 변경을 위한 copyWith
  PromiseModel copyWith({
    String? id,
    String? title,
    List<String>? memberIds,
    GeoPoint? location,
    String? address,
    DateTime? scheduledAt,
    String? chatRoomId,
    bool? isOngoing,
  }) {
    return PromiseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      memberIds: memberIds ?? this.memberIds,
      location: location ?? this.location,
      address: address ?? this.address,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      isOngoing: isOngoing ?? this.isOngoing,
    );
  }
}
