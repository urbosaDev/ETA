import 'package:what_is_your_eta/data/service/notification_api_service.dart';

abstract interface class NotificationApiRepository {
  Future<void> sendGroupNotification({
    required List<String> targetUserIds,
    required String groupName,
    required String message,
    required String groupId,
  });

  Future<void> sendPromiseNotification({
    required List<String> targetUserIds,
    required String title,
    required String body,
    required String groupId,
  });
}

class NotificationApiRepositoryImpl implements NotificationApiRepository {
  final NotificationApiService _fcmService;

  NotificationApiRepositoryImpl({required NotificationApiService fcmService})
    : _fcmService = fcmService;

  @override
  Future<void> sendGroupNotification({
    required List<String> targetUserIds,
    required String groupName,
    required String message,
    required String groupId,
  }) async {
    if (targetUserIds.isEmpty) return;
    await _fcmService.sendFcmMessages(
      targetUserIds: targetUserIds,
      title: '[$groupName]',
      body: message,
      data: {'type': 'group', 'groupId': groupId},
    );
  }

  @override
  Future<void> sendPromiseNotification({
    required List<String> targetUserIds,
    required String title,
    required String body,

    required String groupId,
  }) async {
    if (targetUserIds.isEmpty) return;
    await _fcmService.sendFcmMessages(
      targetUserIds: targetUserIds,
      title: title,
      body: body,
      data: {'type': 'promise', 'groupId': groupId},
    );
  }
}
