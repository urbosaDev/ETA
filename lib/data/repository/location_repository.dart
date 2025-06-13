import 'package:what_is_your_eta/data/model/location_model/promise_location_model.dart';
import 'package:what_is_your_eta/data/model/location_model/user_location_model.dart';
import 'package:what_is_your_eta/data/service/local_map_api_service.dart';

abstract class LocationRepository {
  Future<List<PromiseLocationModel>> searchLocationByKeyword({
    required String keyword,
  });

  Future<List<PromiseLocationModel>> searchPlaceByKeyword({
    required String keyword,
    int page,
  });
  Future<UserLocationModel?> getUserAddressFromCoordinates({
    required double latitude,
    required double longitude,
  });
  // Future<List<PromiseLocationModel>> searchPlaceByCategoryNearby({
  //   required String categoryGroupCode,
  //   required double latitude,
  //   required double longitude,
  //   int page,
  // });

  // Future<PromiseLocationModel?> getAddressFromCoordinates({
  //   required double latitude,
  //   required double longitude,
  // });

  // Future<UserLocationModel?> getUserAddressFromCoordinates({
  //   required double latitude,
  //   required double longitude,
  // });
}

class LocationRepositoryImpl implements LocationRepository {
  final LocalMapApiService _apiService;

  LocationRepositoryImpl({required LocalMapApiService apiService})
    : _apiService = apiService;

  /// 주소 → 좌표 변환 (address.json)
  @override
  Future<List<PromiseLocationModel>> searchLocationByKeyword({
    required String keyword,
  }) async {
    try {
      final data = await _apiService.addressToCoordinate(query: keyword);
      final documents = data['documents'] as List<dynamic>?;

      if (documents == null || documents.isEmpty) return [];

      return documents.map((doc) {
        final roadAddress = doc['road_address'];
        final addressName = doc['address_name'];
        return PromiseLocationModel(
          latitude: double.parse(doc['y']),
          longitude: double.parse(doc['x']),
          placeName: roadAddress?['address_name'] ?? addressName ?? 'Unknown',
          address: roadAddress?['address_name'] ?? addressName ?? 'Unknown',
        );
      }).toList();
    } catch (e) {
      print('searchLocationByKeyword 실패: $e');
      return [];
    }
  }

  /// 키워드로 장소 검색 (keyword.json)
  @override
  Future<List<PromiseLocationModel>> searchPlaceByKeyword({
    required String keyword,
    int page = 1,
  }) async {
    try {
      final data = await _apiService.keywordToPlace(query: keyword, page: page);
      final documents = data['documents'] as List<dynamic>?;

      if (documents == null || documents.isEmpty) return [];

      return documents.map((doc) {
        return PromiseLocationModel(
          latitude: double.parse(doc['y']),
          longitude: double.parse(doc['x']),
          placeName: doc['place_name'] ?? 'Unknown',
          address: doc['road_address_name'] ?? doc['address_name'] ?? 'Unknown',
        );
      }).toList();
    } catch (e) {
      print('searchPlaceByKeyword 실패: $e');
      return [];
    }
  }

  @override
  Future<UserLocationModel?> getUserAddressFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final data = await _apiService.coordinateToAddress(
        longitude: longitude.toString(),
        latitude: latitude.toString(),
      );

      final documents = data['documents'] as List<dynamic>?;

      if (documents == null || documents.isEmpty) return null;

      final first = documents.first;
      final addressInfo = first['address'];
      final roadAddressInfo = first['road_address'];

      return UserLocationModel(
        latitude: latitude,
        longitude: longitude,
        address:
            roadAddressInfo?['address_name'] ??
            addressInfo?['address_name'] ??
            'Unknown',
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      print('getUserAddressFromCoordinates 실패: $e');
      return null;
    }
  }

  /// 카테고리로 장소 검색 (category.json)
  // @override
  // Future<List<PromiseLocationModel>> searchPlaceByCategoryNearby({
  //   required String categoryGroupCode,
  //   required double latitude,
  //   required double longitude,
  //   int page = 1,
  // }) async {
  //   try {
  //     final data = await _apiService.categoryToPlace(
  //       categoryGroupCode: categoryGroupCode,
  //       x: longitude.toString(),
  //       y: latitude.toString(),
  //       page: page,
  //     );
  //     final documents = data['documents'] as List<dynamic>?;

  //     if (documents == null || documents.isEmpty) return [];

  //     return documents.map((doc) {
  //       return PromiseLocationModel(
  //         latitude: double.parse(doc['y']),
  //         longitude: double.parse(doc['x']),
  //         placeName: doc['place_name'] ?? 'Unknown',
  //         address: doc['road_address_name'] ?? doc['address_name'] ?? 'Unknown',
  //       );
  //     }).toList();
  //   } catch (e) {
  //     print('searchPlaceByCategoryNearby 실패: $e');
  //     return [];
  //   }
  // }

  // @override
  // Future<PromiseLocationModel?> getAddressFromCoordinates({
  //   required double latitude,
  //   required double longitude,
  // }) async {
  //   throw UnimplementedError('카카오 reverse geocoding 미구현');
  // }

  // @override
  // Future<UserLocationModel?> getUserAddressFromCoordinates({
  //   required double latitude,
  //   required double longitude,
  // }) async {
  //   throw UnimplementedError('카카오 reverse geocoding 미구현');
  // }
}
