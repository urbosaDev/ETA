class MessageEntity {
  final String id;
  final String senderId;
  final String text;
  final DateTime sentAt;

  /// 체크한 유저들의 uid 리스트/ read표시는 X
  final List<String> checkedUserIds;
  // ⬅️ 약속장소와의 거리 (단위: m)
  final double? distanceFromMeetingPoint;

  MessageEntity({
    required this.id,
    required this.senderId,
    required this.text,
    required this.sentAt,
    this.checkedUserIds = const [],
    this.distanceFromMeetingPoint,
  });
}
