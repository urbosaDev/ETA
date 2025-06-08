import 'package:cloud_firestore/cloud_firestore.dart';

class UserLocationModel {
  final double latitude;
  final double longitude;
  final String address;
  final DateTime updatedAt;

  const UserLocationModel({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.updatedAt,
  });

  factory UserLocationModel.fromJson(Map<String, dynamic> json) {
    return UserLocationModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      address: (json['address'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
