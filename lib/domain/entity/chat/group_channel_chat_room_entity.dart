class GroupChannelChatRoomEntity {
  final String id;
  final List<String> memberIds; // 그룹에 속한 모든 구성원 UID
  final List<String> messageIds;
  final DateTime createdAt;

  const GroupChannelChatRoomEntity({
    required this.id,
    required this.memberIds,
    required this.messageIds,
    required this.createdAt,
  });

  factory GroupChannelChatRoomEntity.empty({
    required String id,
    required List<String> memberIds,
  }) {
    return GroupChannelChatRoomEntity(
      id: id,
      memberIds: memberIds,
      messageIds: const [],
      createdAt: DateTime.now(),
    );
  }
}
