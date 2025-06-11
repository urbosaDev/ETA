import 'package:get/state_manager.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/token_repository.dart';

class SettingViewModel extends GetxController {
  final AuthRepository _authRepository;
  final TokenRepository _tokenRepository;
  SettingViewModel({
    required AuthRepository authRepository,
    required TokenRepository tokenRepository,
  }) : _tokenRepository = tokenRepository,
       _authRepository = authRepository;

  Future<void> signOut() async {
    await _tokenRepository.deleteFcmToken();
    await _authRepository.signOut();
  }
}
