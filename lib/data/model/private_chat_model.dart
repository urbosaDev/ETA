import 'package:cloud_firestore/cloud_firestore.dart';

// 개인 챗 모델은 FireStore에 최상위 컬렉션
// 내부에는 리스트로 message를 가진다.
// 페이징 필수 : 10개씩 가져오기 , 이후 스크롤시 추가 fetch
// 메시지를 id로 찾지 않고, 단순 시간 순 정렬로만 처리
// 각 유저에서 채팅방의 정렬은 lastMessageAt으로 정렬
// createdAt 삭제
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
