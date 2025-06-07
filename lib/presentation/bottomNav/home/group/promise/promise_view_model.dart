import 'dart:async';

// import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/message_model.dart';
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
  final RxMap<String, UserModel> memberMap = <String, UserModel>{}.obs;

  StreamSubscription<UserModel>? _userSub;
  StreamSubscription<PromiseModel>? _promiseSub;

  final RxList<MessageModel> messages = <MessageModel>[].obs;
  StreamSubscription<List<MessageModel>>? _messageSub;

  @override
  void onInit() {
    super.onInit();
    _initialize();
    listenToMessages();
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
    memberMap.value = {for (var u in users) u.uid: u};
  }

  void listenToMessages() {
    _messageSub?.cancel();
    _messageSub = _promiseRepository.streamPromiseMessages(promiseId).listen((
      msgs,
    ) {
      messages.value = msgs;
    });
  }

  Future<void> sendMessage(String content) async {
    if (userModel.value == null) return;
    final msg = MessageModel(
      senderId: userModel.value!.uid,
      text: content,
      sentAt: DateTime.now(),
      readBy: [userModel.value!.uid],
    );
    await _promiseRepository.sendPromiseMessage(promiseId, msg);
  }

  @override
  void onClose() {
    _userSub?.cancel();
    _promiseSub?.cancel();
    _messageSub?.cancel();
    super.onClose();
    // debugPrint('🗑️ 약속 뷰모델 deleted');
  }
}
