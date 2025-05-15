import 'package:get/get.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/service/auth_service.dart';
import 'package:what_is_your_eta/presentation/%08home/home_view_model.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthService>(AuthService());
    Get.put<AuthRepository>(FirebaseAuthRepository(Get.find<AuthService>()));

    Get.put(HomeViewModel(authRepository: Get.find<AuthRepository>()));
  }
}
