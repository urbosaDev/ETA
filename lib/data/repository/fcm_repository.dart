import 'package:what_is_your_eta/data/service/fcm_service.dart';

abstract interface class FcmRepository {
  Future<void> sendGroupNotification({
    required List<Map<String, String>> targetTokens,
    required String groupName,
    required String message,
    required String groupId,
  });

  Future<void> sendPromiseNotification({
    required List<Map<String, String>> targetTokens,
    required String title,
    required String body,
    required String promiseId,
    required String groupId,
  });
}

class FcmRepositoryImpl implements FcmRepository {
  final FcmService _fcmService;

  FcmRepositoryImpl({required FcmService fcmService})
    : _fcmService = fcmService;

  @override
  Future<void> sendGroupNotification({
    required List<Map<String, String>> targetTokens,
    required String groupName,
    required String message,
    required String groupId,
  }) async {
    if (targetTokens.isEmpty) return;
    await _fcmService.sendFcmMessages(
      targetTokens: targetTokens,
      title: '[$groupName]',
      body: message,
      data: {'type': 'group', 'groupId': groupId},
    );
  }

  @override
  Future<void> sendPromiseNotification({
    required List<Map<String, String>> targetTokens,
    required String title,
    required String body,
    required String promiseId,
    required String groupId,
  }) async {
    if (targetTokens.isEmpty) return;
    await _fcmService.sendFcmMessages(
      targetTokens: targetTokens,
      title: title,
      body: body,
      data: {'type': 'promise', promiseId: promiseId, 'groupId': groupId},
    );
  }
}
