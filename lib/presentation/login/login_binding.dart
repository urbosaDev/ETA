import 'package:get/get.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';
import 'package:what_is_your_eta/data/service/auth_service.dart';
import 'package:what_is_your_eta/data/service/user_service.dart';
import 'package:what_is_your_eta/presentation/login/login_view_model.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthService>(AuthService());
    Get.put<UserService>(UserService());
    Get.put<UserRepository>(UserRepositoryImpl(Get.find<UserService>()));
    Get.put<AuthRepository>(FirebaseAuthRepository(Get.find<AuthService>()));
    Get.put<LoginViewModel>(
      LoginViewModel(
        userRepository: Get.find<UserRepository>(),
        authRepository: Get.find<AuthRepository>(),
      ),
    );
  }
}
