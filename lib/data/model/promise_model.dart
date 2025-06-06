import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:what_is_your_eta/data/model/location_model/promise_location_model.dart';
import 'package:what_is_your_eta/data/model/location_model/user_location_model.dart';
import 'package:what_is_your_eta/data/model/penalty_model.dart';

class PromiseModel {
  final String id;
  final String groupId;
  final String name;
  final List<String> memberIds;
  final PromiseLocationModel location;
  final DateTime time;
  final String penalty;
  final List<String> lateUserIds;
  final Map<String, UserLocationModel>? userLocations;

  final Map<String, Penalty>? penaltySuggestions;
  final Penalty? selectedPenalty;

  PromiseModel({
    required this.id,
    required this.groupId,
    required this.name,
    required this.memberIds,
    required this.location,
    required this.time,
    required this.penalty,
    required this.lateUserIds,
    this.userLocations,
    this.penaltySuggestions,
    this.selectedPenalty,
  });

  factory PromiseModel.fromJson(Map<String, dynamic> json) {
    return PromiseModel(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      name: json['name'] as String,
      memberIds: List<String>.from(json['memberIds']),
      location: PromiseLocationModel.fromJson(json['location']),
      time: (json['time'] as Timestamp).toDate(),
      penalty: json['penalty'] as String,
      lateUserIds: List<String>.from(json['lateUserIds']),
      userLocations: (json['userLocations'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, UserLocationModel.fromJson(value)),
      ),
      penaltySuggestions: (json['penaltySuggestions'] as Map<String, dynamic>?)
          ?.map(
            (key, value) =>
                MapEntry(key, Penalty.fromJson(value as Map<String, dynamic>)),
          ),
      selectedPenalty:
          (json['selectedPenalty'] is Map<String, dynamic>)
              ? Penalty.fromJson(
                json['selectedPenalty'] as Map<String, dynamic>,
              )
              : null,
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
      'penalty': penalty,
      'lateUserIds': lateUserIds,
      if (userLocations != null)
        'userLocations': userLocations!.map((k, v) => MapEntry(k, v.toJson())),
      if (penaltySuggestions != null)
        'penaltySuggestions': penaltySuggestions!.map(
          (k, v) => MapEntry(k, v.toJson()),
        ),
      'selectedPenalty': selectedPenalty?.toJson(),
    };
  }
}
