import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:what_is_your_eta/data/model/location_model/promise_location_model.dart';
import 'package:what_is_your_eta/data/model/location_model/user_location_model.dart';

class PromiseModel {
  final String id;
  final String groupId; // 🔹 추가된 필드
  final String name;
  final List<String> memberIds;
  final PromiseLocationModel location;
  final DateTime time;
  final String penalty;
  final List<String> lateUserIds;
  final Map<String, UserLocationModel>? userLocations;

  PromiseModel({
    required this.id,
    required this.groupId, // 🔹 생성자에 포함
    required this.name,
    required this.memberIds,
    required this.location,
    required this.time,
    required this.penalty,
    required this.lateUserIds,
    this.userLocations,
  });

  factory PromiseModel.fromJson(Map<String, dynamic> json) {
    return PromiseModel(
      id: json['id'] as String,
      groupId: json['groupId'] as String, // 🔹 fromJson에 포함
      name: json['name'] as String,
      memberIds: List<String>.from(json['memberIds'] as List),
      location: PromiseLocationModel.fromJson(json['location']),
      time: (json['time'] as Timestamp).toDate(),
      penalty: json['penalty'] as String,
      lateUserIds: List<String>.from(json['lateUserIds'] as List),
      userLocations: (json['userLocations'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(
          key,
          UserLocationModel.fromJson(value as Map<String, dynamic>),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId, // 🔹 toJson에 포함
      'name': name,
      'memberIds': memberIds,
      'location': location.toJson(),
      'time': Timestamp.fromDate(time),
      'penalty': penalty,
      'lateUserIds': lateUserIds,
      if (userLocations != null)
        'userLocations': userLocations!.map(
          (key, value) => MapEntry(key, value.toJson()),
        ),
    };
  }
}
