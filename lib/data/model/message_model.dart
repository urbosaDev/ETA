import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:what_is_your_eta/data/model/location_model/user_location_model.dart';

enum MessageType { text, system, location }

class MessageWithSnapshot {
  final MessageModel model;
  final DocumentSnapshot _snapshot; // 내부 캡슐화

  MessageWithSnapshot({required this.model, required DocumentSnapshot snapshot})
    : _snapshot = snapshot;

  DateTime get sentAt => model.sentAt;

  DocumentSnapshot getSnapshot() => _snapshot;
}

abstract class MessageModel {
  final String senderId;
  final String text;
  final DateTime sentAt;
  final List<String> readBy;
  final MessageType type;

  MessageModel({
    required this.senderId,
    required this.text,
    required this.sentAt,
    required this.type,
    this.readBy = const [],
  });

  Map<String, dynamic> toJson();

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final type = MessageType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => MessageType.text,
    );

    switch (type) {
      case MessageType.text:
        return TextMessageModel.fromJson(json);
      case MessageType.system:
        return SystemMessageModel.fromJson(json);
      case MessageType.location:
        return LocationMessageModel.fromJson(json);
    }
  }
}

class TextMessageModel extends MessageModel {
  TextMessageModel({
    required super.senderId,
    required super.text,
    required super.sentAt,
    super.readBy,
  }) : super(type: MessageType.text);

  factory TextMessageModel.fromJson(Map<String, dynamic> json) {
    return TextMessageModel(
      senderId: json['senderId'],
      text: json['text'],
      sentAt: (json['sentAt'] as Timestamp).toDate(),
      readBy: List<String>.from(json['readBy'] ?? []),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'text': text,
      'sentAt': Timestamp.fromDate(sentAt),
      'type': type.name,
      'readBy': readBy,
    };
  }
}

class SystemMessageModel extends MessageModel {
  SystemMessageModel({required super.text, required super.sentAt, super.readBy})
    : super(senderId: 'system', type: MessageType.system);

  factory SystemMessageModel.fromJson(Map<String, dynamic> json) {
    return SystemMessageModel(
      text: json['text'],
      sentAt: (json['sentAt'] as Timestamp).toDate(),
      readBy: List<String>.from(json['readBy'] ?? []),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'text': text,
      'sentAt': Timestamp.fromDate(sentAt),
      'type': type.name,
      'readBy': readBy,
    };
  }
}

class LocationMessageModel extends MessageModel {
  final UserLocationModel location;

  LocationMessageModel({
    required super.senderId,
    required super.text,
    required super.sentAt,
    required UserLocationModel location,
    super.readBy,
  }) : location = location,
       super(type: MessageType.location);
  factory LocationMessageModel.fromJson(Map<String, dynamic> json) {
    return LocationMessageModel(
      senderId: json['senderId'],
      text: json['text'],
      sentAt: (json['sentAt'] as Timestamp).toDate(),
      location: UserLocationModel.fromJson(json['location']),
      readBy: List<String>.from(json['readBy'] ?? []),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'text': text,
      'sentAt': Timestamp.fromDate(sentAt),
      'type': type.name,
      'readBy': readBy,
      'location': location.toJson(),
    };
  }
}
