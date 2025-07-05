import 'package:get/state_manager.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';

enum AuthStatus { unknown, notLoggedIn, incompleteAccount, loggedIn }

class SplashViewModel extends GetxController {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  SplashViewModel({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  }) : _userRepository = userRepository,
       _authRepository = authRepository;

  final RxBool isCheckLogin = true.obs;
  AuthStatus authStatus = AuthStatus.unknown;

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    isCheckLogin.value = true;
    final start = DateTime.now();
    final user = _authRepository.getCurrentUser();
    if (user == null) {
      authStatus = AuthStatus.notLoggedIn;
      await _waitMinimumSplashTime(start);
      isCheckLogin.value = false;
      return;
    }

    try {
      await user.reload();
      final refreshedUser = _authRepository.getCurrentUser();

      if (refreshedUser == null) {
        authStatus = AuthStatus.notLoggedIn;
      } else {
        final exists = await _userRepository.userExists(refreshedUser.uid);
        if (exists) {
          authStatus = AuthStatus.loggedIn;
        } else {
          // 계정은 있지만 Firestore에는 없음 → 로그아웃 처리
          await _authRepository.signOut();
          authStatus = AuthStatus.incompleteAccount;
        }
      }
    } catch (e) {
      authStatus = AuthStatus.notLoggedIn;
      isCheckLogin.value = false;
    } finally {
      await _waitMinimumSplashTime(start);
      isCheckLogin.value = false;
    }
  }

  Future<void> _waitMinimumSplashTime(DateTime start) async {
    const minSplashDuration = Duration(milliseconds: 1500);
    final elapsed = DateTime.now().difference(start);

    if (elapsed < minSplashDuration) {
      final wait = minSplashDuration - elapsed;
      await Future.delayed(wait);
    }
  }
}
