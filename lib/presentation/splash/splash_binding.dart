import 'package:get/get.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/service/auth_service.dart';
import 'package:what_is_your_eta/presentation/splash/splash_view_model.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthService>(AuthService());
    Get.put<AuthRepository>(FirebaseAuthRepository(Get.find<AuthService>()));
    Get.put<SplashViewModel>(
      SplashViewModel(authRepository: Get.find<AuthRepository>()),
    );
  }
}
