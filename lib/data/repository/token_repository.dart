import 'package:what_is_your_eta/data/service/fcm_token_service.dart';

abstract interface class TokenRepository {
  Future<void> saveFcmToken();
  Future<void> deleteFcmToken();
  void listenTokenRefresh();
}

class FcmTokenRepositoryImpl implements TokenRepository {
  final FcmTokenService _service;

  FcmTokenRepositoryImpl(this._service);

  @override
  Future<void> saveFcmToken() async {
    await _service.saveFcmToken();
  }

  @override
  Future<void> deleteFcmToken() async {
    await _service.deleteFcmToken();
  }

  @override
  void listenTokenRefresh() {
    _service.listenTokenRefresh();
  }
}
