import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/location_model/promise_location_model.dart';
import 'package:what_is_your_eta/data/model/promise_model.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/data/repository/promise_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';

class PromiseInfoViewModel extends GetxController {
  final String promiseId;
  final PromiseRepository _promiseRepository;
  final UserRepository _userRepository;
  PromiseInfoViewModel({
    required this.promiseId,
    required PromiseRepository promiseRepository,
    required UserRepository userRepository,
  }) : _promiseRepository = promiseRepository,
       _userRepository = userRepository;

  final Rxn<PromiseModel> promise = Rxn<PromiseModel>();
  StreamSubscription<PromiseModel>? _promiseSub;
  final RxBool isLoading = true.obs;
  final RxList<UserModel> memberList = <UserModel>[].obs;
  final Rxn<PromiseLocationModel> location = Rxn();
  @override
  void onInit() {
    super.onInit();
    // Initialize any necessary data or streams here
    _initialize();
  }

  @override
  void onClose() {
    // Clean up any resources or streams if necessary
    super.onClose();
    debugPrint('🗑️ PromiseInfoViewModel deleted');
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
      await _fetchMembers(fetchedPromise.memberIds);
    }
    _promiseSub?.cancel();
    _promiseSub = _promiseRepository.streamPromise(promiseId).listen((p) async {
      // 추후 memberIds 변경 감지 로직 추가 가능
      promise.value = p;
      location.value = p.location;
      await _fetchMembers(p.memberIds);
    });
  }

  Future<void> _fetchMembers(List<String> memberIds) async {
    final users = await _userRepository.getUsersByUids(memberIds);
    memberList.value = users;
  }
}


// 이곳에서 보여줘야 할 것, promioseId 로 promise fetch 후 그 정보들을 띄워야함, 
// 시간, 주소 , 참여자 3개로 분류 

// promiseModel 에 PromiseLocationModel 이 있음 
// PromiseLocationModel 에는 주소 정보가 있음
// 이를 어떻게 꺼내지 ? 