import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/location_model/promise_location_model.dart';
import 'package:what_is_your_eta/domain/usecase/%08geo_current_location_usecase.dart';
import 'package:what_is_your_eta/domain/usecase/search_location_usecase.dart';

class SelectLocationViewModel extends GetxController {
  final GetCurrentLocationUseCase _getCurrentLocationUseCase;
  final SearchLocationUseCase _searchLocationUseCase;

  SelectLocationViewModel({
    required GetCurrentLocationUseCase getCurrentLocationUseCase,
    required SearchLocationUseCase searchLocationUseCase,
  }) : _getCurrentLocationUseCase = getCurrentLocationUseCase,
       _searchLocationUseCase = searchLocationUseCase;

  final Rx<PromiseLocationModel?> selectedLocation = Rx<PromiseLocationModel?>(
    null,
  );
  final RxList<PromiseLocationModel> searchResults =
      <PromiseLocationModel>[].obs;
  final Rx<PromiseLocationModel?> currentLocation = Rx<PromiseLocationModel?>(
    null,
  );
  final RxBool isLoading = false.obs;
  final RxBool isNearbySearch = false.obs;

  late NaverMapController _mapController;
  bool _mapReady = false;

  int _currentPage = 1;
  bool _isLastPage = false;
  bool _isFetching = false;
  String lastKeyword = '';

  bool get isLastPage => _isLastPage;

  @override
  void onInit() {
    super.onInit();
    _initCurrentLocation();
  }

  @override
  void onClose() {
    if (_mapReady) {
      _mapController.dispose();
    }
    super.onClose();
  }

  Future<void> _initCurrentLocation() async {
    try {
      isLoading.value = true;

      final pos = await _getCurrentLocationUseCase.call();
      final location = PromiseLocationModel(
        placeName: '현재 위치',
        latitude: pos.latitude,
        longitude: pos.longitude,
        address: '',
      );
      currentLocation.value = location;

      if (_mapReady) {
        _moveCameraTo(location);
      }
    } catch (e) {
      print('현재 위치 가져오기 실패: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void onMapReady(NaverMapController controller) {
    _mapController = controller;
    _mapReady = true;

    final loc = currentLocation.value;
    if (loc != null) {
      _moveCameraTo(loc);
    }
  }

  void _moveCameraTo(PromiseLocationModel location) {
    _mapController.updateCamera(
      NCameraUpdate.withParams(
        target: NLatLng(location.latitude, location.longitude),
        zoom: 14,
      ),
    );
    _mapController.clearOverlays();
    _mapController.addOverlay(
      NMarker(
        id: 'selected_location',
        position: NLatLng(location.latitude, location.longitude),
      ),
    );
  }

  void selectLocation(PromiseLocationModel location) {
    if (selectedLocation.value?.placeName != location.placeName) {
      selectedLocation.value = location;
      _moveCameraTo(location);
    }
  }

  Future<void> searchLocation(String keyword, {bool isFirst = false}) async {
    if (_isFetching || _isLastPage) return;
    _isFetching = true;
    isLoading.value = true;

    if (isFirst) {
      _currentPage = 1;
      _isLastPage = false;
      searchResults.clear();
      lastKeyword = keyword;
    }

    final loc = currentLocation.value;
    if (loc == null) {
      _isFetching = false;
      isLoading.value = false;
      return;
    }

    final results = await _searchLocationUseCase.execute(
      keyword: keyword,
      latitude: loc.latitude,
      longitude: loc.longitude,
      isNearby: isNearbySearch.value,
      page: _currentPage,
    );

    if (results.isEmpty) {
      _isLastPage = true;
    } else {
      _currentPage++;
      searchResults.addAll(results);
    }

    _isFetching = false;
    isLoading.value = false;
  }
}
