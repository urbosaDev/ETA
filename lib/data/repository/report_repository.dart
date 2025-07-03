import 'package:what_is_your_eta/data/model/report_model.dart';
import 'package:what_is_your_eta/data/service/report_service.dart';

abstract class ReportRepository {
  Future<bool> reportUser(ReportModel reportModel);
}

class ReportRepositoryImpl implements ReportRepository {
  final ReportService _reportService;

  ReportRepositoryImpl(this._reportService);

  @override
  Future<bool> reportUser(ReportModel reportModel) async {
    try {
      await _reportService.reportUser(data: reportModel.toMap());
      return true;
    } catch (_) {
      return false;
    }
  }
}
