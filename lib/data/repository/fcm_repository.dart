import 'package:what_is_your_eta/data/service/fcm_service.dart';

abstract interface class FcmRepository {
  Future<void> sendChatNotification({
    required String targetToken,
    required String senderName,
    required String message,
  });

  Future<void> sendGroupNotification({
    required List<String> targetTokens,
    required String groupName,
    required String message,
  });

  Future<void> sendPromiseNotification({
    required List<String> targetTokens,
    required String title,
    required String body,
  });
}

class FcmRepositoryImpl implements FcmRepository {
  final FcmService _fcmService;

  FcmRepositoryImpl({required FcmService fcmService})
    : _fcmService = fcmService;

  @override
  Future<void> sendChatNotification({
    required String targetToken,
    required String senderName,
    required String message,
  }) async {
    await _fcmService.sendFcmMessage(
      targetToken: targetToken,
      title: senderName,
      body: message,
    );
  }

  @override
  Future<void> sendGroupNotification({
    required List<String> targetTokens,
    required String groupName,
    required String message,
  }) async {
    for (final token in targetTokens) {
      await _fcmService.sendFcmMessage(
        targetToken: token,
        title: '[$groupName]',
        body: message,
      );
    }
  }

  @override
  Future<void> sendPromiseNotification({
    required List<String> targetTokens,
    required String title,
    required String body,
  }) async {
    for (final token in targetTokens) {
      await _fcmService.sendFcmMessage(
        targetToken: token,
        title: title,
        body: body,
      );
    }
  }
}
