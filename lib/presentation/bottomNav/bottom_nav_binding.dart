import 'package:get/get.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/service/auth_service.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/home_view_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/bottom_nav_view_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/notification/notification_view_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/setting/setting_view_model.dart';

class BottomNavBinding extends Bindings {
  @override
  void dependencies() {
    // 공통 의존성 주입
    Get.put<AuthService>(AuthService());
    Get.put<AuthRepository>(FirebaseAuthRepository(Get.find<AuthService>()));

    // ViewModels
    Get.put(BottomNavViewModel());
    Get.put(HomeViewModel(authRepository: Get.find<AuthRepository>()));
    Get.put(SettingViewModel(authRepository: Get.find<AuthRepository>()));
    Get.put(NotificationViewModel());
  }
}
