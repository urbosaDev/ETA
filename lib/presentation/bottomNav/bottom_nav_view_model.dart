import 'package:get/state_manager.dart';
import 'package:what_is_your_eta/data/repository/token_repository.dart';

class BottomNavViewModel extends GetxController {
  final currentIndex = 0.obs;
  final FcmTokenRepository _fcmTokenRepository;
  BottomNavViewModel({required FcmTokenRepository fcmTokenRepository})
    : _fcmTokenRepository = fcmTokenRepository;
  void changeIndex(int index) {
    currentIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();

    // listen 등록 → 앱 실행 중 갱신 대응
    _fcmTokenRepository.listenTokenRefresh();

    // 최초 저장
    _fcmTokenRepository.saveFcmToken();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
