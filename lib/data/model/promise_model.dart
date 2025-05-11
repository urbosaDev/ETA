import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:what_is_your_eta/data/model/location_model/promise_location_model.dart';

class PromiseModel {
  final String id;
  final String title;
  final List<String> memberIds;
  final PromiseLocationModel location;
  final DateTime scheduledAt;
  final String chatRoomId;
  final bool isOngoing;

  const PromiseModel({
    required this.id,
    required this.title,
    required this.memberIds,
    required this.location,
    required this.scheduledAt,
    required this.chatRoomId,
    this.isOngoing = true,
  });

  factory PromiseModel.fromJson(Map<String, dynamic> json) {
    return PromiseModel(
      id: json['id'],
      title: json['title'],
      memberIds: List<String>.from(json['memberIds'] ?? []),
      location: PromiseLocationModel.fromJson(json['location']),
      scheduledAt: (json['scheduledAt'] as Timestamp).toDate(),
      chatRoomId: json['chatRoomId'],
      isOngoing: json['isOngoing'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'memberIds': memberIds,
      'location': location.toJson(),
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'chatRoomId': chatRoomId,
      'isOngoing': isOngoing,
    };
  }

  PromiseModel copyWith({
    String? id,
    String? title,
    List<String>? memberIds,
    PromiseLocationModel? location,
    DateTime? scheduledAt,
    String? chatRoomId,
    bool? isOngoing,
  }) {
    return PromiseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      memberIds: memberIds ?? this.memberIds,
      location: location ?? this.location,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      isOngoing: isOngoing ?? this.isOngoing,
    );
  }
}
