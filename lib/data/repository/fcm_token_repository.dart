import 'package:what_is_your_eta/data/service/fcm_token_service.dart';

class FcmTokenRepository {
  final FcmTokenService _service;

  FcmTokenRepository({required FcmTokenService service}) : _service = service;

  Future<void> saveFcmToken() async {
    await _service.saveFcmToken();
  }

  Future<void> deleteFcmToken() async {
    await _service.deleteFcmToken();
  }

  void listenTokenRefresh() {
    _service.listenTokenRefresh();
  }
}
