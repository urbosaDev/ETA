import 'dart:async';

// import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/promise_model.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/promise_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';

class PromiseViewModel extends GetxController {
  final String promiseId;
  final PromiseRepository _promiseRepository;
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  PromiseViewModel({
    required this.promiseId,
    required PromiseRepository promiseRepository,
    required AuthRepository authRepository,
    required UserRepository userRepository,
  }) : _promiseRepository = promiseRepository,
       _authRepository = authRepository,
       _userRepository = userRepository;

  final Rxn<PromiseModel> promise = Rxn<PromiseModel>();
  final RxBool isLoading = true.obs;

  final Rx<UserModel?> userModel = Rx<UserModel?>(null);
  final RxList<UserModel> memberList = <UserModel>[].obs;

  StreamSubscription<UserModel>? _userSub;
  StreamSubscription<PromiseModel>? _promiseSub;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    isLoading.value = true;

    try {
      await _initUser();
      await _initPromiseAndMembers();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _initUser() async {
    final currentUser = _authRepository.getCurrentUser();
    if (currentUser == null) return;

    final initialUser = await _userRepository.getUser(currentUser.uid);
    if (initialUser != null) {
      userModel.value = initialUser;
    }

    _userSub = _userRepository.streamUser(currentUser.uid).listen((user) {
      userModel.value = user;
    });
  }

  Future<void> _initPromiseAndMembers() async {
    final fetchedPromise = await _promiseRepository.getPromise(promiseId);
    if (fetchedPromise != null) {
      promise.value = fetchedPromise;
      await _fetchMembers(fetchedPromise.memberIds);
    }

    _promiseSub = _promiseRepository.streamPromise(promiseId).listen((p) async {
      // 추후 memberIds 변경 감지 로직 추가 가능
      promise.value = p;
      await _fetchMembers(p.memberIds);
    });
  }

  Future<void> _fetchMembers(List<String> memberIds) async {
    final users = await _userRepository.getUsersByUids(memberIds);

    memberList.value = users;
  }

  @override
  void onClose() {
    _userSub?.cancel();
    _promiseSub?.cancel();

    super.onClose();
    // debugPrint('🗑️ 약속 뷰모델 deleted');
  }
}
