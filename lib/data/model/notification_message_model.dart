import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType { group, promise }

class NotificationMessageModel {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final String reciverUid;
  final String groupId;

  final DateTime createdAt;
  final bool isRead;

  NotificationMessageModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.reciverUid,
    required this.groupId,

    required this.createdAt,
    this.isRead = false,
  });

  factory NotificationMessageModel.fromJson(
    String id,
    Map<String, dynamic> json,
  ) {
    return NotificationMessageModel(
      id: id,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.promise,
      ),
      reciverUid: json['reciverUid'],
      groupId: json['groupId'],

      createdAt: (json['createdAt'] as Timestamp).toDate(),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'type': type.name,
      'reciverUid': reciverUid,
      'groupId': groupId,

      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
    };
  }
}
