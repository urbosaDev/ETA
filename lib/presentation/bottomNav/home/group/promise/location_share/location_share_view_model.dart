import 'dart:async';

import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/location_model/promise_location_model.dart';
import 'package:what_is_your_eta/data/model/location_model/user_location_model.dart';
import 'package:what_is_your_eta/data/model/message_model.dart';
import 'package:what_is_your_eta/data/model/promise_model.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/location_repository.dart';
import 'package:what_is_your_eta/data/repository/promise_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';
import 'package:what_is_your_eta/domain/usecase/%08geo_current_location_usecase.dart';
import 'package:what_is_your_eta/domain/usecase/calculate_distance_usecase.dart';

class LocationShareViewModel extends GetxController {
  final String promiseId;
  final GetCurrentLocationUseCase _getCurrentLocationUseCase;
  final LocationRepository _locationRepository;
  final PromiseRepository _promiseRepository;
  final AuthRepository _authRepository;
  final CalculateDistanceUseCase _calculateDistanceUseCase;
  final UserRepository _userRepository;

  LocationShareViewModel({
    required this.promiseId,
    required GetCurrentLocationUseCase getCurrentLocationUseCase,
    required LocationRepository locationRepository,
    required PromiseRepository promiseRepository,
    required AuthRepository authRepository,
    required CalculateDistanceUseCase calculateDistanceUseCase,
    required UserRepository userRepository,
  }) : _getCurrentLocationUseCase = getCurrentLocationUseCase,
       _locationRepository = locationRepository,
       _promiseRepository = promiseRepository,
       _authRepository = authRepository,
       _calculateDistanceUseCase = calculateDistanceUseCase,
       _userRepository = userRepository;

  // final RxBool isSharing = false.obs;

  final RxBool isLoading = false.obs;
  final Rx<UserLocationModel?> currentLocation = Rx<UserLocationModel?>(null);
  final Rx<PromiseLocationModel?> promiseLocation = Rx<PromiseLocationModel?>(
    null,
  );
  final RxDouble distanceToPromiseMeters = 0.0.obs;
  final Rx<PromiseModel?> promise = Rx<PromiseModel?>(null);
  final RxString successMessage = ''.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isUpdating = false.obs;
  StreamSubscription<PromiseModel>? _promiseSub;
  final RxBool isAlreadyArrived = false.obs;
  @override
  void onInit() {
    super.onInit();
    fetchLocationData();
    fetchPromise();
  }

  Future<void> fetchLocationData() async {
    try {
      isLoading.value = true;

      await _fetchPromiseLocation();
      await initCurrentLocation();

      // userLoc, promiseLoc 체크 후 distance 계산
      final userLoc = currentLocation.value;
      final promiseLoc = promiseLocation.value;

      if (userLoc == null || promiseLoc == null) {
        errorMessage.value = '위치 정보를 불러오지 못했습니다.';
        distanceToPromiseMeters.value = 0.0; // 안전하게 초기화
        return;
      }

      final distance = _calculateDistanceUseCase.calculateDistance(
        startLat: userLoc.latitude,
        startLng: userLoc.longitude,
        endLat: promiseLoc.latitude,
        endLng: promiseLoc.longitude,
      );

      distanceToPromiseMeters.value = distance;
    } catch (e) {
      errorMessage.value = '위치 정보를 불러오는 중 오류가 발생했습니다: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPromise() async {
    final uid = _authRepository.getCurrentUid();
    promise.value = await _promiseRepository.getPromise(promiseId);
    _updateIsAlreadyArrived(uid);

    _promiseSub = _promiseRepository.streamPromise(promiseId).listen((p) {
      promise.value = p;
      _updateIsAlreadyArrived(uid);
    });
  }

  void _updateIsAlreadyArrived(String? uid) {
    isAlreadyArrived.value =
        promise.value?.arriveUserIds.contains(uid) ?? false;
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
    } else {}
  }

  Future<void> updateUserLocation() async {
    final currentUid = _authRepository.getCurrentUid();
    if (currentUid == null) {
      errorMessage.value = '사용자 정보를 불러올 수 없습니다.';
      return;
    }
    final sendCurrentLocation = currentLocation.value;
    if (sendCurrentLocation == null) {
      errorMessage.value = '현재 위치 정보를 불러올 수 없습니다.';
      return;
    }

    try {
      isUpdating.value = true;

      // Firestore userLocations 업데이트
      await _promiseRepository.updateUserLocation(
        promiseId: promiseId,
        uid: currentUid,
        userLocation: sendCurrentLocation,
      );

      // 채팅방에 위치 메시지 전송
      final promiseLoc = promiseLocation.value;
      String extraText = '';
      if (promiseLoc != null) {
        final distance = distanceToPromiseMeters.value;
        extraText =
            '(${sendCurrentLocation.address}, 거리: ${distance.toStringAsFixed(1)} m)';
      } else {
        extraText = sendCurrentLocation.address;
      }

      final locationMessage = LocationMessageModel(
        location: sendCurrentLocation,
        senderId: currentUid,
        sentAt: DateTime.now(),
        text: '위치공유 $extraText',
        readBy: [],
      );

      await _promiseRepository.sendPromiseMessage(promiseId, locationMessage);

      successMessage.value = '위치가 성공적으로 업데이트 및 공유되었습니다.';
    } catch (e) {
      errorMessage.value = '위치 업데이트/공유 실패: $e';
      return;
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> arriveLocation() async {
    // 거리 확인
    // 약속시간 확인,
    // 해당하면 업데이트
    // promise 내에 lateUserIds -> arriveUserIds 로 변경
    final currentUid = _authRepository.getCurrentUid();
    if (isAlreadyArrived.value) {
      errorMessage.value = '이미 도착하셨습니다.';
      return;
    }
    if (currentUid == null) {
      errorMessage.value = '사용자 정보를 불러올 수 없습니다.';
      return;
    }

    final distance = distanceToPromiseMeters.value;
    if (distance > 100) {
      errorMessage.value =
          '약속 장소에 도착하지 않았습니다. 거리: ${distance.toStringAsFixed(1)} m';
      return;
    }

    final currentPromiseTime = promise.value?.time;
    if (currentPromiseTime == null) {
      errorMessage.value = '약속 시간을 불러올 수 없습니다.';
      return;
    }

    final now = DateTime.now();

    if (currentPromiseTime.isBefore(now)) {
      errorMessage.value = '약속 시간이 지났습니다. 도착할 수 없습니다.';
      return;
    }

    if (now.isBefore(currentPromiseTime.subtract(const Duration(hours: 1)))) {
      errorMessage.value = '약속 1시간 전부터 도착 확인이 가능합니다.';
      return;
    }

    try {
      await _promiseRepository.addArriveUserIdIfNotExists(
        promiseId: promise.value!.id,
        currentUid: currentUid,
      );
      final user = await _userRepository.getUser(currentUid);

      final systemMessage = SystemMessageModel(
        text: '🎉 ${user?.name ?? '익명 사용자'}님이 도착했습니다!',
        sentAt: DateTime.now(),
      );

      await _promiseRepository.sendPromiseMessage(promiseId, systemMessage);

      successMessage.value = '도착이 성공적으로 기록되었습니다.';
    } catch (e) {
      errorMessage.value = '도착 기록 중 오류 발생: $e';
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

// 도착버튼, 애초에 도착버튼을 안찍으면 지각임. 
