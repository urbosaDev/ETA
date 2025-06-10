import 'dart:math';

import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/location_model/promise_location_model.dart';
import 'package:what_is_your_eta/data/model/location_model/user_location_model.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/location_repository.dart';
import 'package:what_is_your_eta/data/repository/promise_repository.dart';
import 'package:what_is_your_eta/domain/usecase/%08geo_current_location_usecase.dart';

class LocationShareModalViewModel extends GetxController {
  final String promiseId;
  final GetCurrentLocationUseCase _getCurrentLocationUseCase;
  final LocationRepository _locationRepository;
  final PromiseRepository _promiseRepository;
  final AuthRepository _authRepository;

  LocationShareModalViewModel({
    required this.promiseId,
    required GetCurrentLocationUseCase getCurrentLocationUseCase,
    required LocationRepository locationRepository,
    required PromiseRepository promiseRepository,
    required AuthRepository authRepository,
  }) : _getCurrentLocationUseCase = getCurrentLocationUseCase,
       _locationRepository = locationRepository,
       _promiseRepository = promiseRepository,
       _authRepository = authRepository;

  // final RxBool isSharing = false.obs;

  final RxBool isLoading = false.obs;
  final Rx<UserLocationModel?> currentLocation = Rx<UserLocationModel?>(null);
  final Rx<PromiseLocationModel?> promiseLocation = Rx<PromiseLocationModel?>(
    null,
  );
  final RxDouble distanceToPromiseMeters = 0.0.obs;

  final RxString successMessage = ''.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isUpdating = false.obs;

  @override
  void onInit() {
    super.onInit();
    initLocationData();
  }

  Future<void> initLocationData() async {
    try {
      isLoading.value = true;

      await _fetchPromiseLocation();
      await initCurrentLocation(); // 기존거 재사용

      _updateDistanceToPromise();
    } catch (e) {
      print('initLocationData 실패: $e');
    } finally {
      isLoading.value = false;
    }
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

  Future<void> _fetchPromiseLocation() async {
    final promise = await _promiseRepository.getPromise(promiseId);
    if (promise != null) {
      promiseLocation.value = promise.location;
      print('약속 위치: ${promiseLocation.value?.address}');
    } else {
      print('약속 정보를 불러오지 못했습니다.');
    }
  }

  @override
  void onClose() {
    super.onClose();
  }

  void _updateDistanceToPromise() {
    final userLoc = currentLocation.value;
    final promiseLoc = promiseLocation.value;

    if (userLoc == null || promiseLoc == null) {
      distanceToPromiseMeters.value = 0.0;
      return;
    }

    final distance = _calculateDistance(
      userLoc.latitude,
      userLoc.longitude,
      promiseLoc.latitude,
      promiseLoc.longitude,
    );

    print('약속장소까지 거리: ${distance.toStringAsFixed(1)} m');
    distanceToPromiseMeters.value = distance;
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371000; // meters

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a =
        (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            (sin(dLon / 2) * sin(dLon / 2));

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degree) {
    return degree * pi / 180;
  }

  Future<void> updateUserLocation() async {
    final currentUid = _authRepository.getCurrentUid();
    if (currentUid == null) {
      errorMessage.value = '사용자 정보를 불러올 수 없습니다.';
      return;
    }
    final sendCurrentLocation = this.currentLocation.value;
    if (sendCurrentLocation == null) {
      errorMessage.value = '현재 위치 정보를 불러올 수 없습니다.';
      return;
    }
    try {
      isUpdating.value = true;
      await _promiseRepository.updateUserLocation(
        promiseId: promiseId,
        uid: currentUid,
        userLocation: sendCurrentLocation,
      );
      successMessage.value = '위치가 성공적으로 업데이트되었습니다.';
    } catch (e) {
      errorMessage.value = '위치 업데이트 실패: $e';
      return;
    } finally {
      isUpdating.value = false;
    }
  }

  void clearMessages() {
    successMessage.value = '';
    errorMessage.value = '';
  }
}

// 위치공유 버튼 하나만 만들기 
// 1. 업데이트를 하는 버튼, 
//  final Map<String, UserLocationModel>? userLocations; 를 업데이트 해야함. 
// 현재 유저를 불러와야함. userModel을 불러올 필요는 없고 auth 사용 
// 무엇을 공유해야하나 ? -> currentLocation , 거리도 추가. 
// UseCase 분리 , 그리고 거리는 업데이트하지말고 그때그때 계산 