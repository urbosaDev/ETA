import 'package:cloud_firestore/cloud_firestore.dart';

class UserLocationModel {
  final double latitude;
  final double longitude;
  final DateTime updatedAt;

  const UserLocationModel({
    required this.latitude,
    required this.longitude,
    required this.updatedAt,
  });

  UserLocationModel copyWith({
    double? latitude,
    double? longitude,
    DateTime? updatedAt,
  }) {
    return UserLocationModel(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory UserLocationModel.fromJson(Map<String, dynamic> json) {
    return UserLocationModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
