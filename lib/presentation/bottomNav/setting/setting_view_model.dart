import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/notification_client_repository.dart';

import 'package:what_is_your_eta/data/repository/user_%08repository.dart';

class SettingViewModel extends GetxController {
  final AuthRepository _authRepository;
  final NotificationClientRepository _fcmTokenRepository;
  final UserRepository _userRepository;

  SettingViewModel({
    required AuthRepository authRepository,
    required NotificationClientRepository fcmTokenRepository,
    required UserRepository userRepository,
  }) : _fcmTokenRepository = fcmTokenRepository,
       _authRepository = authRepository,
       _userRepository = userRepository;
  final RxBool isSignedOut = false.obs;

  Future<void> signOut() async {
    isLoading.value = true;
    try {
      await _fcmTokenRepository.deleteFcmToken();
      await _authRepository.signOut();
    } catch (e) {
      isLoading.value = false;
      return;
    }

    isSignedOut.value = true;
  }

  @override
  void onInit() {
    _loadNotificationSetting();
    super.onInit();
  }

  final RxBool isLoading = false.obs;
  final RxBool isDeleting = false.obs;
  Future<void> deleteAccount() async {
    isLoading.value = true;
    final user = _authRepository.getCurrentUser()?.uid;
    if (user == null) {
      isLoading.value = false;
      return;
    }

    try {
      await _fcmTokenRepository.deleteFcmToken();

      await _userRepository.deleteUser(user);
      await _authRepository.deleteAccount();
      isDeleting.value = true;
    } catch (e) {
      isLoading.value = false;
      return;
    } finally {
      isLoading.value = false;
    }
  }

  final RxBool isNotificationEnabled = true.obs;

  Future<void> _loadNotificationSetting() async {
    final prefs = await SharedPreferences.getInstance();
    isNotificationEnabled.value = prefs.getBool('notification_enabled') ?? true;
  }

  Future<void> updateNotificationSetting(bool isEnabled) async {
    isLoading.value = true;
    final myUserId = _authRepository.getCurrentUser()?.uid;
    if (myUserId == null) return;

    final prefs = await SharedPreferences.getInstance();

    try {
      if (isEnabled) {
        await _fcmTokenRepository.subscribeToUserTopic(myUserId);
      } else {
        await _fcmTokenRepository.unsubscribeFromUserTopic(myUserId);
      }

      isNotificationEnabled.value = isEnabled;
      await prefs.setBool('notification_enabled', isEnabled);
      print('✅ 알림 설정이 성공적으로 변경되었습니다: $isEnabled');
    } catch (e) {
      print('❌ 알림 설정 변경 실패: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
