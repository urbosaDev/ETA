import 'dart:async';

import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/location_model/promise_location_model.dart';
import 'package:what_is_your_eta/data/model/location_model/user_location_model.dart';
import 'package:what_is_your_eta/data/model/promise_model.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/promise_repository.dart';
import 'package:what_is_your_eta/domain/usecase/location_share_usecase.dart';

class LocationShareViewModel extends GetxController {
  final String promiseId;
  final LocationShareUseCase _locationShareUseCase;
  final PromiseRepository _promiseRepository;
  final AuthRepository _authRepository;

  LocationShareViewModel({
    required this.promiseId,
    required LocationShareUseCase locationShareUseCase,
    required PromiseRepository promiseRepository,
    required AuthRepository authRepository,
  }) : _locationShareUseCase = locationShareUseCase,
       _promiseRepository = promiseRepository,
       _authRepository = authRepository;

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

  @override
  void onClose() {
    _promiseSub?.cancel();
    super.onClose();
  }

  Future<void> fetchLocationData() async {
    try {
      isLoading.value = true;

      // UseCase 사용
      final pLoc = await _locationShareUseCase.getPromiseLocation(promiseId);
      final uLoc = await _locationShareUseCase.getCurrentUserLocation();

      promiseLocation.value = pLoc;
      currentLocation.value = uLoc;

      if (uLoc == null) {
        errorMessage.value = '위치 정보를 불러오지 못했습니다.';
        distanceToPromiseMeters.value = 0.0;
        return;
      }

      final distance = _locationShareUseCase.calculateDistance(
        userLocation: uLoc,
        promiseLocation: pLoc,
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

      final uLoc = await _locationShareUseCase.getCurrentUserLocation();
      currentLocation.value = uLoc;

      // distance 재계산
      final pLoc = promiseLocation.value;
      if (uLoc != null && pLoc != null) {
        final distance = _locationShareUseCase.calculateDistance(
          userLocation: uLoc,
          promiseLocation: pLoc,
        );
        distanceToPromiseMeters.value = distance;
      }
    } catch (e) {
      currentLocation.value = null;
      errorMessage.value = '위치 정보를 불러오는 중 오류가 발생했습니다: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateUserLocation() async {
    final currentUid = _authRepository.getCurrentUid();
    if (currentUid == null) {
      errorMessage.value = '사용자 정보를 불러올 수 없습니다.';
      return;
    }

    final uLoc = currentLocation.value;
    final pLoc = promiseLocation.value;
    final distance = distanceToPromiseMeters.value;

    if (uLoc == null || pLoc == null) {
      errorMessage.value = '위치 정보를 불러올 수 없습니다.';
      return;
    }

    try {
      isUpdating.value = true;

      await _locationShareUseCase.updateUserLocationAndSendMessage(
        promiseId: promiseId,
        currentUid: currentUid,
        userLocation: uLoc,
        promiseLocation: pLoc,
        distanceMeters: distance,
        groupId: promise.value!.groupId,
      );

      successMessage.value = '위치가 성공적으로 업데이트 및 공유되었습니다.';
    } catch (e) {
      errorMessage.value = '위치 업데이트/공유 실패: $e';
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> arriveLocation() async {
    final currentUid = _authRepository.getCurrentUid();
    if (currentUid == null) {
      errorMessage.value = '사용자 정보를 불러올 수 없습니다.';
      return;
    }

    final distance = distanceToPromiseMeters.value;
    final promiseTime = promise.value?.time;
    if (promiseTime == null) {
      errorMessage.value = '약속 시간을 불러올 수 없습니다.';
      return;
    }

    final result = await _locationShareUseCase.canUserArrive(
      distanceMeters: distance,
      promiseTime: promiseTime,
      isAlreadyArrived: isAlreadyArrived.value,
    );

    if (!result.canArrive) {
      errorMessage.value = result.errorMessage;
      return;
    }

    try {
      await _locationShareUseCase.markUserArrived(
        promiseId: promise.value!.id,
        currentUid: currentUid,
        groupId: promise.value!.groupId,
      );

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
