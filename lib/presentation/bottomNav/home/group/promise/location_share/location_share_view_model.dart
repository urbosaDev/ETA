import 'package:get/get.dart';

class LocationShareModalViewModel extends GetxController {
  final RxBool isSharing = false.obs;

  void startSharing() {
    isSharing.value = true;
    // 위치 공유 로직 시작 (예: 위치 스트림 시작 등)
  }

  void stopSharing() {
    isSharing.value = false;
    // 위치 공유 종료
  }

  @override
  void onClose() {
    stopSharing();

    super.onClose();
  }
}
