import 'package:get/get.dart';

class PenaltyContainerViewModel extends GetxController {
  final String promiseId;

  PenaltyContainerViewModel({required this.promiseId});

  final RxInt currentPage = 0.obs;
  void setCurrentPage(int page) {
    if (currentPage.value != page) {
      currentPage.value = page;
    }
  }
}
