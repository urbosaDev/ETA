import 'package:get/state_manager.dart';
import 'package:what_is_your_eta/data/repository/fcm_token_repository.dart';

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

    _fcmTokenRepository.listenTokenRefresh();

    _fcmTokenRepository.saveFcmToken();
  }

  final Rxn<String> pendingGroupId = Rxn<String>();

  void requestGoToGroup(String groupId) {
    pendingGroupId.value = groupId;
    changeIndex(0);
  }

  void requestGoToHome() {
    changeIndex(0);
  }
}
