import 'package:firebase_messaging/firebase_messaging.dart';
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

  final Rxn<Map<String, String>> fcmNotification = Rxn<Map<String, String>>();
  @override
  void onInit() {
    super.onInit();

    // listen 등록 → 앱 실행 중 갱신 대응
    _tokenRepository.listenTokenRefresh();

    // 최초 저장
    _tokenRepository.saveFcmToken();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.notification?.title ?? '';
      final body = message.notification?.body ?? '';

      print('✅ FCM 포그라운드 수신 → $title - $body');

      // 상태 변경 → View에서 감지해서 Snackbar 띄울 수 있도록
      fcmNotification.value = {'title': title, 'body': body};
    });
  }

  @override
  void onClose() {
    _tokenRepository.deleteFcmToken();

    super.onClose();
  }
}
