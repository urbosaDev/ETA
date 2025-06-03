import 'package:get/state_manager.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';

enum AuthStatus { unknown, notLoggedIn, needsProfile, loggedIn }

class SplashViewModel extends GetxController {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  SplashViewModel({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  }) : _userRepository = userRepository,
       _authRepository = authRepository;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  var isLoading = true.obs;

  final Rx<AuthStatus> authStatus = AuthStatus.unknown.obs;

  void checkLoginStatus() async {
    isLoading.value = true;

    final user = _authRepository.getCurrentUser();
    if (user == null) {
      authStatus.value = AuthStatus.notLoggedIn;
      isLoading.value = false;
      return;
    }

    try {
      await user.reload();
      final refreshedUser = _authRepository.getCurrentUser();

      if (refreshedUser == null) {
        authStatus.value = AuthStatus.notLoggedIn;
      } else {
        final exists = await _userRepository.userExists(refreshedUser.uid);
        authStatus.value =
            exists ? AuthStatus.loggedIn : AuthStatus.needsProfile;
      }
    } catch (e) {
      authStatus.value = AuthStatus.notLoggedIn;
    }

    isLoading.value = false;
  }
}
