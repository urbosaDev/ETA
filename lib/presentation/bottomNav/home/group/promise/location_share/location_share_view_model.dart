import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/location_model/user_location_model.dart';
import 'package:what_is_your_eta/domain/usecase/%08geo_current_location_usecase.dart';
import 'package:what_is_your_eta/domain/usecase/search_location_usecase.dart';

class LocationShareModalViewModel extends GetxController {
  final GetCurrentLocationUseCase _getCurrentLocationUseCase;
  final SearchLocationUseCase _searchLocationUseCase;

  LocationShareModalViewModel({
    required GetCurrentLocationUseCase getCurrentLocationUseCase,
    required SearchLocationUseCase searchLocationUseCase,
  }) : _getCurrentLocationUseCase = getCurrentLocationUseCase,
       _searchLocationUseCase = searchLocationUseCase;

  // final RxBool isSharing = false.obs;

  final RxBool isLoading = false.obs;
  final Rx<UserLocationModel?> currentLocation = Rx<UserLocationModel?>(null);

  @override
  void onInit() {
    super.onInit();
    _initCurrentLocation();
  }

  Future<void> _initCurrentLocation() async {
    try {
      isLoading.value = true;

      final pos = await _getCurrentLocationUseCase.fetchCurrentPosition();
      final location = UserLocationModel(
        latitude: pos.latitude,
        longitude: pos.longitude,
        address: '', // 현재는 빈 문자열로 초기화 (필요 시 reverse geocoding으로 주소 추가 가능)
        updatedAt: DateTime.now(),
      );
      currentLocation.value = location;
    } catch (e) {
      // print('현재 위치 가져오기 실패: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
