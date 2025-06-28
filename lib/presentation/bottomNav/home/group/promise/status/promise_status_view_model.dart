import 'dart:async';

import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/location_model/promise_location_model.dart';
import 'package:what_is_your_eta/data/model/location_model/user_location_model.dart';
import 'package:what_is_your_eta/data/model/promise_model.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/data/repository/promise_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';
import 'package:what_is_your_eta/domain/usecase/calculate_distance_usecase.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/model/promise_member_status.dart';

class PromiseStatusViewModel extends GetxController {
  final String promiseId;
  final PromiseRepository _promiseRepository;
  final UserRepository _userRepository;
  final CalculateDistanceUseCase _calculateDistanceUseCase;
  PromiseStatusViewModel({
    required this.promiseId,
    required PromiseRepository promiseRepository,
    required UserRepository userRepository,
    required CalculateDistanceUseCase calculateDistanceUseCase,
  }) : _promiseRepository = promiseRepository,
       _userRepository = userRepository,
       _calculateDistanceUseCase = calculateDistanceUseCase;

  final Rxn<PromiseModel> promise = Rxn<PromiseModel>();
  final RxBool isLoading = true.obs;
  final Rxn<PromiseLocationModel> location = Rxn();
  final RxList<UserModel> memberList = <UserModel>[].obs;
  StreamSubscription<PromiseModel>? promiseSub;
  final RxMap<String, UserLocationModel> userLocations = RxMap();
  final Rxn<PromiseMemberStatus> selectedUser = Rxn<PromiseMemberStatus>();

  final Rxn<NaverMapController> mapController = Rxn<NaverMapController>();
  Rxn<UserLocationModel> selectedUserLocation = Rxn<UserLocationModel>();

  PromiseLocationModel? get defaultLocation => location.value;
  @override
  void onInit() {
    super.onInit();
    // Initialize any necessary data or streams here
    _initialize();
  }

  Future<void> _initialize() async {
    isLoading.value = true;

    try {
      await _initPromiseAndMembers();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _initPromiseAndMembers() async {
    final fetchedPromise = await _promiseRepository.getPromise(promiseId);
    if (fetchedPromise != null) {
      promise.value = fetchedPromise;
      location.value = fetchedPromise.location;
      userLocations.value = fetchedPromise.userLocations ?? {};
      await _fetchMembers(fetchedPromise.memberIds);
    }

    promiseSub = _promiseRepository.streamPromise(promiseId).listen((p) async {
      promise.value = p;
      location.value = p.location;
      userLocations.value = p.userLocations ?? {};
      await _fetchMembers(p.memberIds);
    });
  }

  Future<void> _fetchMembers(List<String> memberIds) async {
    final users = await _userRepository.getUsersByUids(memberIds);
    memberList.value = users;
  }

  List<PromiseMemberStatus> get promiseMemberStatusList {
    final targetLat = location.value?.latitude;
    final targetLng = location.value?.longitude;

    return memberList.map((user) {
      final loc = userLocations[user.uid];

      double? distance;
      if (loc != null && targetLat != null && targetLng != null) {
        distance = _calculateDistanceUseCase.calculateDistance(
          startLat: loc.latitude,
          startLng: loc.longitude,
          endLat: targetLat,
          endLng: targetLng,
        );
      }

      final updateStatus =
          loc == null
              ? MemberUpdateStatus.notUpdated
              : MemberUpdateStatus.updated;

      return PromiseMemberStatus(
        user: user,
        location: loc,
        distance: distance,
        updateStatus: updateStatus,
        address: loc?.address,
      );
    }).toList();
  }

  void selectUser(PromiseMemberStatus user) async {
    selectedUser.value = user;

    final mapCtrl = mapController.value;
    final location = user.location;

    if (mapCtrl != null && location != null) {
      await mapCtrl.clearOverlays();

      await Future.delayed(const Duration(milliseconds: 100));

      await mapCtrl.addOverlay(
        NMarker(
          id: 'selected-user-marker',
          position: NLatLng(location.latitude, location.longitude),
        ),
      );

      await mapCtrl.updateCamera(
        NCameraUpdate.withParams(
          target: NLatLng(location.latitude, location.longitude),
          zoom: 15,
        ),
      );
    }
  }

  NLatLng? get currentLatLng {
    if (selectedUserLocation.value != null) {
      return NLatLng(
        selectedUserLocation.value!.latitude,
        selectedUserLocation.value!.longitude,
      );
    } else if (defaultLocation != null) {
      return NLatLng(defaultLocation!.latitude, defaultLocation!.longitude);
    } else {
      return null;
    }
  }

  @override
  void onClose() {
    promiseSub?.cancel();
    mapController.value?.dispose();
    super.onClose();
  }
}
