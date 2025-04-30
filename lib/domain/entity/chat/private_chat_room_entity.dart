class PrivateChatRoomEntity {
  final String id;
  final List<String> participantIds; // 항상 두 명의 UID가 들어감
  final List<String> messageIds;
  final DateTime createdAt;
  // final DateTime updatedAt; // message는 수정 불가

  const PrivateChatRoomEntity({
    required this.id,
    required this.participantIds,
    required this.messageIds,
    required this.createdAt,
    // required this.updatedAt,
  });

  factory PrivateChatRoomEntity.empty({
    required String id,
    required List<String> participants,
  }) {
    return PrivateChatRoomEntity(
      id: id,
      participantIds: participants,
      messageIds: const [],
      createdAt: DateTime.now(),
    );
  }
}
