import 'package:what_is_your_eta/data/model/location_model/promise_location_model.dart';
import 'package:what_is_your_eta/data/model/location_model/user_location_model.dart';
import 'package:what_is_your_eta/data/model/message_model.dart';
import 'package:what_is_your_eta/data/repository/location_repository.dart';
import 'package:what_is_your_eta/data/repository/promise_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';
import 'package:what_is_your_eta/domain/usecase/%08geo_current_location_usecase.dart';
import 'package:what_is_your_eta/domain/usecase/calculate_distance_usecase.dart';

class LocationShareUseCase {
  final GetCurrentLocationUseCase _getCurrentLocationUseCase;
  final LocationRepository _locationRepository;
  final PromiseRepository _promiseRepository;
  final UserRepository _userRepository;
  final CalculateDistanceUseCase _calculateDistanceUseCase;

  LocationShareUseCase({
    required GetCurrentLocationUseCase getCurrentLocationUseCase,
    required LocationRepository locationRepository,
    required PromiseRepository promiseRepository,
    required UserRepository userRepository,
    required CalculateDistanceUseCase calculateDistanceUseCase,
  }) : _getCurrentLocationUseCase = getCurrentLocationUseCase,
       _locationRepository = locationRepository,
       _promiseRepository = promiseRepository,
       _userRepository = userRepository,
       _calculateDistanceUseCase = calculateDistanceUseCase;

  //  현재 위치 + 주소 가져오기
  Future<UserLocationModel?> getCurrentUserLocation() async {
    final pos = await _getCurrentLocationUseCase.fetchCurrentPosition();
    final userLocation = await _locationRepository
        .getUserAddressFromCoordinates(
          latitude: pos.latitude,
          longitude: pos.longitude,
        );
    return userLocation;
  }

  //  PromiseLocation 가져오기
  Future<PromiseLocationModel> getPromiseLocation(String promiseId) async {
    final promise = await _promiseRepository.getPromise(promiseId);
    if (promise == null) {
      throw Exception('Promise 정보를 불러올 수 없습니다.');
    }
    return promise.location;
  }

  //  거리 계산
  double calculateDistance({
    required UserLocationModel userLocation,
    required PromiseLocationModel promiseLocation,
  }) {
    return _calculateDistanceUseCase.calculateDistance(
      startLat: userLocation.latitude,
      startLng: userLocation.longitude,
      endLat: promiseLocation.latitude,
      endLng: promiseLocation.longitude,
    );
  }

  //  위치 업데이트 + 메시지 전송
  Future<void> updateUserLocationAndSendMessage({
    required String promiseId,
    required String currentUid,
    required UserLocationModel userLocation,
    required PromiseLocationModel promiseLocation,
    required double distanceMeters,
  }) async {
    // Firestore 업데이트
    await _promiseRepository.updateUserLocation(
      promiseId: promiseId,
      uid: currentUid,
      userLocation: userLocation,
    );

    // 메시지 전송
    final locationMessage = LocationMessageModel(
      location: userLocation,
      senderId: currentUid,
      sentAt: DateTime.now(),
      text:
          '위치공유 (${userLocation.address}, 거리: ${distanceMeters.toStringAsFixed(1)} m)',
      readBy: [],
    );

    await _promiseRepository.sendPromiseMessage(promiseId, locationMessage);
  }

  //  도착 가능 여부 판단
  Future<CanUserArriveResult> canUserArrive({
    required double distanceMeters,
    required DateTime promiseTime,
    required bool isAlreadyArrived,
  }) async {
    final now = DateTime.now();

    if (isAlreadyArrived) {
      return CanUserArriveResult(false, '이미 도착하셨습니다.');
    }

    if (distanceMeters > 100) {
      return CanUserArriveResult(
        false,
        '약속 장소에 도착하지 않았습니다. 거리: ${distanceMeters.toStringAsFixed(1)} m',
      );
    }

    if (promiseTime.isBefore(now)) {
      return CanUserArriveResult(false, '약속 시간이 지났습니다. 도착할 수 없습니다.');
    }

    if (now.isBefore(promiseTime.subtract(const Duration(hours: 1)))) {
      return CanUserArriveResult(false, '약속 1시간 전부터 도착 확인이 가능합니다.');
    }

    return CanUserArriveResult(true, '');
  }

  //  도착 처리
  Future<void> markUserArrived({
    required String promiseId,
    required String currentUid,
  }) async {
    await _promiseRepository.addArriveUserIdIfNotExists(
      promiseId: promiseId,
      currentUid: currentUid,
    );

    final user = await _userRepository.getUser(currentUid);

    final systemMessage = SystemMessageModel(
      text: '🎉 ${user?.name ?? '익명 사용자'}님이 도착했습니다!',
      sentAt: DateTime.now(),
    );

    await _promiseRepository.sendPromiseMessage(promiseId, systemMessage);
  }
}

class CanUserArriveResult {
  final bool canArrive;
  final String errorMessage;

  CanUserArriveResult(this.canArrive, this.errorMessage);
}
