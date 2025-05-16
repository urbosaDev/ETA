import 'package:get/state_manager.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';

class SplashViewModel extends GetxController {
  final AuthRepository _authRepository;
  SplashViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  void onInit() {
    super.onInit();
    // InIt 시에 로그인 상태 확인하고 상태를 바꿔야함
    checkLoginStatus();
  }

  var isLoggedIn = false.obs;
  var isLoading = true.obs;

  void checkLoginStatus() async {
    isLoading.value = true;
    isLoggedIn.value = _authRepository.isSignedIn();
    isLoading.value = false;
  }
}
