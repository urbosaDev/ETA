class PromiseLocationModel {
  final double latitude;
  final double longitude;
  final String placeName;
  final String address;

  const PromiseLocationModel({
    required this.latitude,
    required this.longitude,
    required this.placeName,
    required this.address,
  });

  PromiseLocationModel copyWith({
    double? latitude,
    double? longitude,
    String? placeName,
    String? address,
  }) {
    return PromiseLocationModel(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      placeName: placeName ?? this.placeName,
      address: address ?? this.address,
    );
  }

  factory PromiseLocationModel.fromJson(Map<String, dynamic> json) {
    return PromiseLocationModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      placeName: json['placeName'] as String,
      address: json['address'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'placeName': placeName,
      'address': address,
    };
  }
}
