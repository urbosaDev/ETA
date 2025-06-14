import 'dart:async';

import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/promise_model.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/promise_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';

class LateViewModel extends GetxController {
  final String promiseId;
  final PromiseRepository _promiseRepository;
  final UserRepository _userRepository;
  final AuthRepository _authRepository;

  LateViewModel({
    required this.promiseId,
    required PromiseRepository promiseRepository,
    required UserRepository userRepository,
    required AuthRepository authRepository,
  }) : _promiseRepository = promiseRepository,
       _userRepository = userRepository,
       _authRepository = authRepository;

  final Rxn<PromiseModel> promise = Rxn<PromiseModel>();
  StreamSubscription<PromiseModel>? _promiseSub;
  final RxList<UserModel> memberList = <UserModel>[].obs;
  final Rx<UserModel?> userModel = Rx<UserModel?>(null);

  final RxBool isAfterPromiseTime = false.obs;
  final RxList<UserModel> arrivedUsers = <UserModel>[].obs;
  final RxList<UserModel> lateUsers = <UserModel>[].obs;

  final RxBool isLoading = true.obs;
  @override
  void onInit() {
    // TODO: implement onInit
    _initialize();
    super.onInit();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    _promiseSub?.cancel();
    super.onClose();
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
  }

  Future<void> _initPromiseAndMembers() async {
    final fetchedPromise = await _promiseRepository.getPromise(promiseId);
    if (fetchedPromise != null) {
      promise.value = fetchedPromise;
      _evaluateTimeAndCategorize(fetchedPromise);
      await _fetchMembers(fetchedPromise.memberIds);
    }

    _promiseSub = _promiseRepository.streamPromise(promiseId).listen((p) async {
      promise.value = p;
      _evaluateTimeAndCategorize(p);
      await _fetchMembers(p.memberIds);
    });
  }

  void _evaluateTimeAndCategorize(PromiseModel p) {
    isAfterPromiseTime.value = DateTime.now().isAfter(p.time);

    final arrivedIds = p.arriveUserIds;
    final allMembers = memberList;

    arrivedUsers.value =
        allMembers.where((u) => arrivedIds.contains(u.uid)).toList();
    lateUsers.value =
        allMembers.where((u) => !arrivedIds.contains(u.uid)).toList();
  }

  Future<void> _fetchMembers(List<String> memberIds) async {
    final users = await _userRepository.getUsersByUids(memberIds);

    memberList.value = users;
  }
}

// 순서대로
