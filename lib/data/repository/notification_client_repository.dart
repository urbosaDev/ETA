import 'package:what_is_your_eta/data/service/notification_client_service.dart';

class NotificationClientRepository {
  final NotificationClientService _service;

  NotificationClientRepository({required NotificationClientService service})
    : _service = service;

  Future<void> saveFcmToken() async {
    await _service.saveFcmToken();
  }

  Future<void> deleteFcmToken() async {
    await _service.deleteFcmToken();
  }

  void listenTokenRefresh() {
    _service.listenTokenRefresh();
  }

  Future<void> subscribeToUserTopic(String userId) async {
    await _service.subscribeToUserTopic(userId);
  }

  Future<void> unsubscribeFromUserTopic(String userId) async {
    await _service.unsubscribeFromUserTopic(userId);
  }
}
