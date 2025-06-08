import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/location_model/user_location_model.dart';
import 'package:what_is_your_eta/data/repository/location_repository.dart';
import 'package:what_is_your_eta/domain/usecase/%08geo_current_location_usecase.dart';

class LocationShareModalViewModel extends GetxController {
  final GetCurrentLocationUseCase _getCurrentLocationUseCase;
  final LocationRepository _locationRepository;

  LocationShareModalViewModel({
    required GetCurrentLocationUseCase getCurrentLocationUseCase,
    required LocationRepository locationRepository,
  }) : _getCurrentLocationUseCase = getCurrentLocationUseCase,
       _locationRepository = locationRepository;

  // final RxBool isSharing = false.obs;

  final RxBool isLoading = false.obs;
  final Rx<UserLocationModel?> currentLocation = Rx<UserLocationModel?>(null);

  @override
  void onInit() {
    super.onInit();
    initCurrentLocation();
  }

  Future<void> initCurrentLocation() async {
    try {
      isLoading.value = true;

      final pos = await _getCurrentLocationUseCase.fetchCurrentPosition();

      final userLocation = await _locationRepository
          .getUserAddressFromCoordinates(
            latitude: pos.latitude,
            longitude: pos.longitude,
          );

      currentLocation.value = userLocation;
      print(currentLocation.value?.address);
      print(currentLocation.value?.updatedAt);
    } catch (e) {
      currentLocation.value = null; // 에러 시 null 처리
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
