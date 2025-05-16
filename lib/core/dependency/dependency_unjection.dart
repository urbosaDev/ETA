import 'package:get/get.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';
import 'package:what_is_your_eta/data/service/auth_service.dart';
import 'package:what_is_your_eta/data/service/user_service.dart';

class DependencyInjection {
  static void init() {
    Get.put<AuthService>(AuthService(), permanent: true);
    Get.put<UserService>(UserService(), permanent: true);

    Get.put<AuthRepository>(
      FirebaseAuthRepository(Get.find()),
      permanent: true,
    );
    Get.put<UserRepository>(UserRepositoryImpl(Get.find()), permanent: true);
  }
}
