import 'package:what_is_your_eta/data/model/location_model/promise_location_model.dart';
import 'package:what_is_your_eta/data/repository/location_repository.dart';

class SearchLocationUseCase {
  final LocationRepository _locationRepository;

  SearchLocationUseCase({required LocationRepository locationRepository})
    : _locationRepository = locationRepository;

  Future<List<PromiseLocationModel>> execute({
    required String keyword,
    required double latitude,
    required double longitude,
    required bool isNearby,
    required int page,
  }) async {
    if (isNearby) {
      final categoryCode = _getCategoryCodeFromKeyword(keyword);
      if (categoryCode == null) return [];

      return await _locationRepository.searchPlaceByCategoryNearby(
        categoryGroupCode: categoryCode,
        latitude: latitude,
        longitude: longitude,
        page: page, // 추가
      );
    }

    final addressResults = await _locationRepository.searchLocationByKeyword(
      keyword: keyword,
      page: page, // 추가
    );

    final placeResults = await _locationRepository.searchPlaceByKeyword(
      keyword: keyword,
      page: page, // 추가
    );

    return {...addressResults, ...placeResults}.toList();
  }

  String? _getCategoryCodeFromKeyword(String keyword) {
    final lower = keyword.toLowerCase();
    if (lower.contains('카페')) return 'CE7';
    if (lower.contains('편의점')) return 'CS2';
    if (lower.contains('은행')) return 'BK9';
    if (lower.contains('음식') || lower.contains('식당')) return 'FD6';
    if (lower.contains('병원')) return 'HP8';
    if (lower.contains('주유소')) return 'OL7';
    return null;
  }
}
