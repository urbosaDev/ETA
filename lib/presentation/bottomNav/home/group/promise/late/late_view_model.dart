import 'dart:async';

import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/promise_model.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/promise_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';
import 'package:what_is_your_eta/domain/usecase/get_friends_with_status_usecase.dart';
import 'package:what_is_your_eta/presentation/models/friend_info_model.dart';

class LateViewModel extends GetxController {
  final String promiseId;
  final PromiseRepository _promiseRepository;
  final UserRepository _userRepository;
  final AuthRepository _authRepository;
  final GetFriendsWithStatusUsecase _getFriendsWithStatusUsecase;

  LateViewModel({
    required this.promiseId,
    required PromiseRepository promiseRepository,
    required UserRepository userRepository,
    required AuthRepository authRepository,
    required GetFriendsWithStatusUsecase getFriendsWithStatusUsecase,
  }) : _promiseRepository = promiseRepository,
       _userRepository = userRepository,
       _authRepository = authRepository,
       _getFriendsWithStatusUsecase = getFriendsWithStatusUsecase;

  final Rxn<PromiseModel> promise = Rxn<PromiseModel>();
  StreamSubscription<PromiseModel>? _promiseSub;
  final RxList<FriendInfoModel> memberList = <FriendInfoModel>[].obs;
  final Rx<UserModel?> userModel = Rx<UserModel?>(null);

  final RxBool isAfterPromiseTime = false.obs;
  final RxList<FriendInfoModel> arrivedUsers = <FriendInfoModel>[].obs;
  final RxList<FriendInfoModel> lateUsers = <FriendInfoModel>[].obs;

  final RxBool isLoading = true.obs;
  @override
  void onInit() {
    _initialize();
    super.onInit();
  }

  @override
  void onClose() {
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
        allMembers.where((u) => arrivedIds.contains(u.userModel.uid)).toList();
    lateUsers.value =
        allMembers.where((u) => !arrivedIds.contains(u.userModel.uid)).toList();
  }

  Future<void> _fetchMembers(List<String> memberIds) async {
    final users = await _getFriendsWithStatusUsecase.assignStatusToUsers(
      uids: memberIds,
    );
    memberList.value = users;
  }
}
