import 'package:get/get.dart';
import 'package:what_is_your_eta/data/repository/promise_repository.dart';

class PromisePenaltyViewModel extends GetxController {
  final String promiseId;
  final PromiseRepository _promiseRepository;
  PromisePenaltyViewModel({
    required this.promiseId,
    required PromiseRepository promiseRepository,
  }) : _promiseRepository = promiseRepository;
}
