import 'dart:async';

import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/message_model.dart';
import 'package:what_is_your_eta/data/model/promise_model.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/data/repository/promise_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';

class PromisePaymentViewModel extends GetxController {
  final String promiseId;
  final UserRepository _userRepository;
  final PromiseRepository _promiseRepository;

  PromisePaymentViewModel({
    required this.promiseId,
    required UserRepository userRepository,
    required PromiseRepository promiseRepository,
  }) : _userRepository = userRepository,
       _promiseRepository = promiseRepository;

  final Rxn<PromiseModel> promise = Rxn<PromiseModel>();
  final RxBool isLoading = true.obs;
  final RxList<UserModel> memberList = <UserModel>[].obs;
  final RxInt totalAmount = 0.obs;
  final RxList<UserModel> selectedMembers = <UserModel>[].obs;
  final RxString bankName = ''.obs;
  final RxString accountNumber = ''.obs;
  final RxInt perPersonAmount = 0.obs;

  StreamSubscription<PromiseModel>? _promiseSub;

  @override
  void onInit() {
    super.onInit();
    _initialize();
    ever(totalAmount, (_) => _calculatePerPerson());
    ever(selectedMembers, (_) => _calculatePerPerson());
  }

  void toggleMember(UserModel user) {
    if (selectedMembers.contains(user)) {
      selectedMembers.remove(user);
    } else {
      selectedMembers.add(user);
    }
  }

  void setBankName(String val) => bankName.value = val;
  void setAccountNumber(String val) => accountNumber.value = val;

  void _calculatePerPerson() {
    final count = selectedMembers.length;
    final amount = totalAmount.value;
    perPersonAmount.value = count == 0 ? 0 : (amount / count).floor();
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
      await _fetchMembers(fetchedPromise.memberIds);
    }

    _promiseSub?.cancel();
    _promiseSub = _promiseRepository.streamPromise(promiseId).listen((p) async {
      promise.value = p;
      await _fetchMembers(p.memberIds);
    });
  }

  Future<void> _fetchMembers(List<String> memberIds) async {
    final users = await _userRepository.getUsersByUids(memberIds);
    memberList.value = users;
  }

  // 알리기 버튼을 누르면 , bool 을 내뱉고, 이를 통해 이동
  Future<bool> notifyPayment() async {
    if (selectedMembers.isEmpty || bankName.isEmpty || accountNumber.isEmpty) {
      return false; // 필수 정보가 없으면 실패
    }
    final content =
        '결제 알림: ${bankName.value} 계좌로 ${accountNumber.value}에 ${perPersonAmount.value}원을 입금해 주세요.';
    final msg = MessageModel(
      senderId: 'system',
      text: content,
      sentAt: DateTime.now(),
    );
    try {
      await _promiseRepository.sendPromiseMessage(promiseId, msg);
      return true; // 성공적으로 알림 전송
    } catch (e) {
      return false; // 알림 전송 실패
    }
  }

  @override
  void onClose() {
    _promiseSub?.cancel();
    super.onClose();
  }
}
