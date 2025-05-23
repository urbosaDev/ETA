import 'package:get/get.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';
import 'package:what_is_your_eta/presentation/splash/splash_view_model.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SplashViewModel>(
      SplashViewModel(
        authRepository: Get.find<AuthRepository>(),
        userRepository: Get.find<UserRepository>(),
      ),
    );
  }
}
