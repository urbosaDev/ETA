import 'package:cloud_firestore/cloud_firestore.dart';

class PromiseChatRoomEntity {
  final String id;
  final String title; // 예: 5월 5일 고기약속
  final List<String> participantIds; // 그룹 내에서 선택된 사람들
  final GeoPoint location; // 약속 장소 (Naver Map 기반)
  final DateTime scheduledAt; // 약속 시간
  final List<String> messageIds;
  final DateTime createdAt;

  const PromiseChatRoomEntity({
    required this.id,
    required this.title,
    required this.participantIds,
    required this.location,
    required this.scheduledAt,
    required this.messageIds,
    required this.createdAt,
  });

  factory PromiseChatRoomEntity.empty({
    required String id,
    required String title,
    required List<String> participantIds,
    required GeoPoint location,
    required DateTime scheduledAt,
  }) {
    return PromiseChatRoomEntity(
      id: id,
      title: title,
      participantIds: participantIds,
      location: location,
      scheduledAt: scheduledAt,
      messageIds: const [],
      createdAt: DateTime.now(),
    );
  }
}
