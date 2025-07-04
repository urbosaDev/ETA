import 'package:what_is_your_eta/data/model/location_model/promise_location_model.dart';
import 'package:what_is_your_eta/data/repository/location_repository.dart';

enum SearchType { keyword, address }

class SearchLocationUseCase {
  final LocationRepository _locationRepository;

  int _currentPage = 1;
  bool _isLastPage = false;
  bool _isFetching = false;

  final List<PromiseLocationModel> _accumulatedResults = [];

  SearchType _currentSearchType = SearchType.keyword;
  String _currentKeyword = '';

  SearchLocationUseCase({required LocationRepository locationRepository})
    : _locationRepository = locationRepository;

  List<PromiseLocationModel> get accumulatedResults =>
      List.unmodifiable(_accumulatedResults);
  bool get isLastPage => _isLastPage;

  Future<void> searchFirstPage({
    required String keyword,
    required SearchType searchType,
  }) async {
    if (_isFetching) return;
    _isFetching = true;

    _currentSearchType = searchType;
    _currentKeyword = keyword.trim();

    _currentPage = 1;
    _isLastPage = false;
    _accumulatedResults.clear();

    if (_currentKeyword.isEmpty) {
      _isFetching = false;
      return;
    }

    if (searchType == SearchType.keyword) {
      final results = await _locationRepository.searchPlaceByKeyword(
        keyword: _currentKeyword,
        page: _currentPage,
      );

      _accumulatedResults.addAll(results);

      if (results.length < 10) {
        _isLastPage = true;
      }
    } else {
      final results = await _locationRepository.searchLocationByKeyword(
        keyword: _currentKeyword,
      );

      _accumulatedResults.addAll(results);
      _isLastPage = true;
    }

    _isFetching = false;
  }

  Future<void> loadNextPage() async {
    if (_isFetching || _isLastPage || _currentSearchType != SearchType.keyword) {
      return;
    }

    _isFetching = true;

    _currentPage++;

    final results = await _locationRepository.searchPlaceByKeyword(
      keyword: _currentKeyword,
      page: _currentPage,
    );

    _accumulatedResults.addAll(results);

    if (results.length < 10) {
      _isLastPage = true;
    }

    _isFetching = false;
  }
}
