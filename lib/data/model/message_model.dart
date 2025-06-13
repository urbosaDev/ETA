import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:what_is_your_eta/data/model/location_model/user_location_model.dart';

enum MessageType { text, system, location }

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
    required String senderId,
    required String text,
    required DateTime sentAt,
    List<String> readBy = const [],
  }) : super(
         senderId: senderId,
         text: text,
         sentAt: sentAt,
         type: MessageType.text,
         readBy: readBy,
       );

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
  SystemMessageModel({
    required String text,
    required DateTime sentAt,
    List<String> readBy = const [],
  }) : super(
         senderId: 'system',
         text: text,
         sentAt: sentAt,
         type: MessageType.system,
         readBy: readBy,
       );

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
    required String senderId,
    required String text,
    required DateTime sentAt,
    required UserLocationModel location,
    List<String> readBy = const [],
  }) : location = location,
       super(
         senderId: senderId,
         text: text,
         sentAt: sentAt,
         type: MessageType.location,
         readBy: readBy,
       );
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
