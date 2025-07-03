enum ReportReason {
  inappropriateProfile,
  inappropriateMessage,
  inappropriateNickname,
}

class ReportModel {
  final String reporterUid;

  final String reportedUid;
  final List<ReportReason> reasons;
  final DateTime reportedAt;

  ReportModel({
    required this.reporterUid,
    required this.reportedUid,
    required this.reasons,
    required this.reportedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'reporterId': reporterUid,
      'targetUserId': reportedUid,
      'reasons': reasons.map((e) => e.name).toList(),
      'reportedAt': reportedAt,
    };
  }
}
