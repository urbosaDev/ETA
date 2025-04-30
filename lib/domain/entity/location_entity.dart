// Location Entity는 보다 범용적으로 작성
// 1. 약속 장소로 사용
// 2. 사용자의 위치 계산에 사용

class LocationEntity {
  final double latitude;
  final double longitude;
  final String? address;
  final String? placeName;
  final DateTime? updatedAt;

  const LocationEntity({
    required this.latitude,
    required this.longitude,
    this.address,
    this.placeName,
    this.updatedAt,
  });

  /// 약속 장소용 생성자
  factory LocationEntity.forPromise({
    required double latitude,
    required double longitude,
    required String address,
    required String placeName,
  }) {
    return LocationEntity(
      latitude: latitude,
      longitude: longitude,
      address: address,
      placeName: placeName,
    );
  }

  /// 사용자 현재 위치용 생성자
  factory LocationEntity.forUser({
    required double latitude,
    required double longitude,
  }) {
    return LocationEntity(
      latitude: latitude,
      longitude: longitude,
      updatedAt: DateTime.now(),
    );
  }

  factory LocationEntity.empty() =>
      const LocationEntity(latitude: 0, longitude: 0);
}
