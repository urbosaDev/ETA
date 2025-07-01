import 'package:get/get.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/fcm_token_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';

class SettingViewModel extends GetxController {
  final AuthRepository _authRepository;
  final FcmTokenRepository _fcmTokenRepository;
  final UserRepository _userRepository;
  SettingViewModel({
    required AuthRepository authRepository,
    required FcmTokenRepository fcmTokenRepository,
    required UserRepository userRepository,
  }) : _fcmTokenRepository = fcmTokenRepository,
       _authRepository = authRepository,
       _userRepository = userRepository;
  final RxBool isSignedOut = false.obs;

  Future<void> signOut() async {
    await _fcmTokenRepository.deleteFcmToken();
    await _authRepository.signOut();

    isSignedOut.value = true;
  }

  final RxBool isDeleting = false.obs;
  Future<void> deleteAccount() async {
    final user = _authRepository.getCurrentUser()?.uid;
    if (user == null) {
      return;
    }
    try {
      await _fcmTokenRepository.deleteFcmToken();
      await _userRepository.deleteAllMessagesFromUser(user);
      await _userRepository.deleteUser(user);
      await _authRepository.deleteAccount();
      isDeleting.value = true;
    } catch (e) {
      return;
    } finally {}
  }
}
