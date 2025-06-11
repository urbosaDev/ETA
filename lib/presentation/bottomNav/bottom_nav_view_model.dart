import 'package:get/state_manager.dart';
import 'package:what_is_your_eta/data/repository/token_repository.dart';

class BottomNavViewModel extends GetxController {
  final currentIndex = 0.obs;
  final TokenRepository _tokenRepository;
  BottomNavViewModel({required TokenRepository tokenRepository})
    : _tokenRepository = tokenRepository;
  void changeIndex(int index) {
    currentIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();

    // listen 등록 → 앱 실행 중 갱신 대응
    _tokenRepository.listenTokenRefresh();

    // 최초 저장
    _tokenRepository.saveFcmToken();
  }

  @override
  void onClose() {
    _tokenRepository.deleteFcmToken();

    super.onClose();
  }
}
