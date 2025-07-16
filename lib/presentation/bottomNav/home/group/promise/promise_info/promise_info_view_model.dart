import 'dart:async';

import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/location_model/promise_location_model.dart';
import 'package:what_is_your_eta/data/model/location_model/user_location_model.dart';
import 'package:what_is_your_eta/data/model/promise_model.dart';
import 'package:what_is_your_eta/data/repository/promise_repository.dart';
import 'package:what_is_your_eta/domain/usecase/calculate_distance_usecase.dart';
import 'package:what_is_your_eta/domain/usecase/get_friends_with_status_usecase.dart';
import 'package:what_is_your_eta/presentation/models/friend_info_model.dart';
import 'package:what_is_your_eta/presentation/models/promise_member_status.dart';

class PromiseInfoViewModel extends GetxController {
  final String promiseId;
  final PromiseRepository _promiseRepository;

  final CalculateDistanceUseCase _calculateDistanceUseCase;
  final GetFriendsWithStatusUsecase _getFriendsWithStatusUsecase;
  PromiseInfoViewModel({
    required this.promiseId,
    required PromiseRepository promiseRepository,

    required CalculateDistanceUseCase calculateDistanceUseCase,
    required GetFriendsWithStatusUsecase getFriendsWithStatusUsecase,
  }) : _promiseRepository = promiseRepository,

       _calculateDistanceUseCase = calculateDistanceUseCase,
       _getFriendsWithStatusUsecase = getFriendsWithStatusUsecase;

  final Rxn<PromiseModel> promise = Rxn<PromiseModel>();
  StreamSubscription<PromiseModel>? _promiseSub;
  final RxBool isLoading = true.obs;
  final RxList<FriendInfoModel> memberList = <FriendInfoModel>[].obs;
  final Rxn<PromiseLocationModel> location = Rxn();

  final Rx<NLatLng?> currentPosition = Rx<NLatLng?>(null);
  final Rxn<NaverMapController> mapController = Rxn<NaverMapController>();
  final RxMap<String, UserLocationModel> userLocations = RxMap();
  final Rxn<PromiseMemberStatus> selectedUser = Rxn<PromiseMemberStatus>();
  @override
  void onInit() {
    super.onInit();

    _initialize();
  }

  @override
  void onClose() {
    _promiseSub?.cancel();
    mapController.value?.dispose();
    super.onClose();
    print('약속아웃');
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
      final latLng = NLatLng(
        fetchedPromise.location.latitude,
        fetchedPromise.location.longitude,
      );
      currentPosition.value = latLng;

      await _fetchMembers(fetchedPromise.memberIds);
    }

    _promiseSub = _promiseRepository.streamPromise(promiseId).listen((p) async {
      promise.value = p;
      location.value = p.location;
      userLocations.value = p.userLocations ?? {};
      await _fetchMembers(p.memberIds);
    });
  }

  Future<void> _fetchMembers(List<String> memberIds) async {
    final users = await _getFriendsWithStatusUsecase.assignStatusToUsers(
      uids: memberIds,
    );
    memberList.value = users;
  }

  List<PromiseMemberStatus> get promiseMemberStatusList {
    final targetLat = location.value?.latitude;
    final targetLng = location.value?.longitude;

    return memberList.map((user) {
      final loc = userLocations[user.userModel.uid];

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

  void setThisPosition(NLatLng latLng) {
    currentPosition.value = latLng;
    _updateMarkerAndCamera(latLng);
  }

  void _updateMarkerAndCamera(NLatLng latLng) {
    final controller = mapController.value;
    if (controller == null) return;

    controller.clearOverlays();
    controller.addOverlay(NMarker(id: 'selected_location', position: latLng));
    controller.updateCamera(NCameraUpdate.withParams(target: latLng, zoom: 16));
  }

  Future<void> setPromiseLocation() async {
    final loc = location.value;
    if (loc == null) return;
    final latLng = NLatLng(loc.latitude, loc.longitude);
    setThisPosition(latLng);
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
}
