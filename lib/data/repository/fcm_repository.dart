import 'package:what_is_your_eta/data/service/fcm_service.dart';

abstract interface class FcmRepository {
  Future<void> sendChatNotification({
    required List<String> targetTokens,
    required String senderName,
    required String message,
  });

  Future<void> sendGroupNotification({
    required List<String> targetTokens,
    required String groupName,
    required String message,
    required String groupId,
  });

  Future<void> sendPromiseNotification({
    required List<String> targetTokens,
    required String title,
    required String body,
    required String promiseId,
  });
}

class FcmRepositoryImpl implements FcmRepository {
  final FcmService _fcmService;

  FcmRepositoryImpl({required FcmService fcmService})
    : _fcmService = fcmService;

  @override
  Future<void> sendChatNotification({
    required List<String> targetTokens,
    required String senderName,
    required String message,
  }) async {
    if (targetTokens.isEmpty) return;
    await _fcmService.sendFcmMessages(
      targetTokens: targetTokens,
      title: senderName,
      body: message,
    );
  }

  @override
  Future<void> sendGroupNotification({
    required List<String> targetTokens,
    required String groupName,
    required String message,
    required String groupId,
  }) async {
    if (targetTokens.isEmpty) return;
    await _fcmService.sendFcmMessages(
      targetTokens: targetTokens,
      title: '[$groupName]',
      body: message,
      data: {'type': 'group', 'promiseId': groupId},
    );
  }

  @override
  Future<void> sendPromiseNotification({
    required List<String> targetTokens,
    required String title,
    required String body,
    required String promiseId,
  }) async {
    if (targetTokens.isEmpty) return;
    await _fcmService.sendFcmMessages(
      targetTokens: targetTokens,
      title: title,
      body: body,
      data: {'type': 'promise', 'promiseId': promiseId},
    );
  }
}
