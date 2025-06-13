import 'dart:math';

class CalculateDistanceUseCase {
  double calculateDistance({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) {
    const earthRadius = 6371000; // meters

    final dLat = _degreesToRadians(endLat - startLat);
    final dLon = _degreesToRadians(endLng - startLng);

    final a =
        (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_degreesToRadians(startLat)) *
            cos(_degreesToRadians(endLat)) *
            (sin(dLon / 2) * sin(dLon / 2));

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degree) {
    return degree * pi / 180;
  }
}
