import 'dart:async';

import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/promise_model.dart';
import 'package:what_is_your_eta/data/repository/promise_repository.dart';

class ViewPenaltyViewModel extends GetxController {
  final String promiseId;
  final PromiseRepository _promiseRepository;

  ViewPenaltyViewModel({
    required this.promiseId,
    required PromiseRepository promiseRepository,
  }) : _promiseRepository = promiseRepository;
  final Rxn<PromiseModel> promise = Rxn<PromiseModel>();
  StreamSubscription<PromiseModel>? _promiseSub;
  final RxBool isLoading = true.obs;
  @override
  void onInit() {
    super.onInit();
    _initialize();
    // Initialize any necessary data or state here
  }

  Future<void> _initialize() async {
    isLoading.value = true;

    try {
      await _initPromise();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _initPromise() async {
    final fetchedPromise = await _promiseRepository.getPromise(promiseId);
    if (fetchedPromise != null) {
      promise.value = fetchedPromise;
    }

    _promiseSub = _promiseRepository.streamPromise(promiseId).listen((p) async {
      promise.value = p;
    });
  }

  bool get hasSelectedPenalty {
    return promise.value?.selectedPenalty != null;
  }
}
