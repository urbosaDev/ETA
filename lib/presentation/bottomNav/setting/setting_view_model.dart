import 'package:get/state_manager.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/token_repository.dart';

class SettingViewModel extends GetxController {
  final AuthRepository _authRepository;
  final FcmTokenRepository _fcmTokenRepository;
  SettingViewModel({
    required AuthRepository authRepository,
    required FcmTokenRepository fcmTokenRepository,
  }) : _fcmTokenRepository = fcmTokenRepository,
       _authRepository = authRepository;

  Future<void> signOut() async {
    await _fcmTokenRepository.deleteFcmToken();
    await _authRepository.signOut();
  }
}
