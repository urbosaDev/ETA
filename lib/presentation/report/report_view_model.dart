import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/report_model.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/report_repository.dart';

class ReportViewModel extends GetxController {
  final String reportedId;
  final ReportRepository _reportRepository;
  final AuthRepository _authRepository;
  ReportViewModel({
    required this.reportedId,
    required ReportRepository reportRepository,
    required AuthRepository authRepository,
  }) : _reportRepository = reportRepository,
       _authRepository = authRepository;

  final RxSet<ReportReason> selectedReasons = <ReportReason>{}.obs;
  void toggleReason(ReportReason reason) {
    if (selectedReasons.contains(reason)) {
      selectedReasons.remove(reason);
    } else {
      selectedReasons.add(reason);
    }
  }

  Map<ReportReason, String> reportReasonLabels = {
    ReportReason.inappropriateProfile: '부적절한 프로필 (사진/배너)',
    ReportReason.inappropriateMessage: '부적절한 메시지 (채팅)',
    ReportReason.inappropriateNickname: '부적절한 닉네임',
  };
  bool isSelected(ReportReason reason) => selectedReasons.contains(reason);

  bool get canSubmit => selectedReasons.isNotEmpty;
  final RxBool success = false.obs;
  Future<void> submitReport() async {
    final reporter = _authRepository.getCurrentUser();
    if (reporter == null) {
      // 로그인 안 되어 있음. 에러 처리
      throw Exception('로그인한 사용자만 신고할 수 있습니다.');
    }

    final report = ReportModel(
      reporterUid: reporter.uid,
      reportedUid: reportedId,
      reasons: selectedReasons.toList(),
      reportedAt: DateTime.now(),
    );

    success.value = await _reportRepository.reportUser(report);
  }
}
