import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:what_is_your_eta/data/model/location_model/promise_location_model.dart';
import 'package:what_is_your_eta/data/model/location_model/user_location_model.dart';

class PromiseModel {
  final String id;
  final String groupId;
  final String name;
  final List<String> memberIds;
  final PromiseLocationModel location;
  final DateTime time;

  final List<String> arriveUserIds;
  final Map<String, UserLocationModel>? userLocations;

  final bool notify1HourScheduled;
  final bool notifyStartScheduled;
  PromiseModel({
    required this.id,
    required this.groupId,
    required this.name,
    required this.memberIds,
    required this.location,
    required this.time,

    required this.arriveUserIds,
    required this.notify1HourScheduled,
    required this.notifyStartScheduled,
    this.userLocations,
  });

  factory PromiseModel.fromJson(Map<String, dynamic> json) {
    return PromiseModel(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      name: json['name'] as String,
      memberIds: List<String>.from(json['memberIds']),
      location: PromiseLocationModel.fromJson(json['location']),
      time: (json['time'] as Timestamp).toDate(),

      arriveUserIds: List<String>.from(json['arriveUserIds']),
      userLocations: (json['userLocations'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, UserLocationModel.fromJson(value)),
      ),

      notify1HourScheduled: json['notify1HourScheduled'] as bool? ?? false,
      notifyStartScheduled: json['notifyStartScheduled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'name': name,
      'memberIds': memberIds,
      'location': location.toJson(),
      'time': Timestamp.fromDate(time),

      'arriveUserIds': arriveUserIds,
      if (userLocations != null)
        'userLocations': userLocations!.map((k, v) => MapEntry(k, v.toJson())),

      'notify1HourScheduled': notify1HourScheduled,
      'notifyStartScheduled': notifyStartScheduled,
    };
  }
}
