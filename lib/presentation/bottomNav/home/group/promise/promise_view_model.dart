import 'package:get/get.dart';

class PromiseViewModel extends GetxController {
  final String promiseId;

  PromiseViewModel({required this.promiseId});

  final RxInt currentPage = 0.obs;
  void setCurrentPage(int page) {
    if (currentPage.value != page) {
      currentPage.value = page;
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
