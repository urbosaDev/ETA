import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:what_is_your_eta/presentation/bottomNav/bottom_nav_binding.dart';
import 'package:what_is_your_eta/presentation/bottomNav/bottom_nav_view.dart';
import 'package:what_is_your_eta/presentation/login/login_binding.dart';
import 'package:what_is_your_eta/presentation/login/login_view.dart';
import 'package:what_is_your_eta/presentation/login/unique_id_input/unique_id_input_binding.dart';
import 'package:what_is_your_eta/presentation/login/unique_id_input/unique_id_input_view.dart';
import 'package:what_is_your_eta/presentation/splash/splash_binding.dart';
import 'package:what_is_your_eta/presentation/splash/splash_view.dart';

abstract class Routes {
  static const splash = '/splash';
  static const login = '/login';

  static const uniqueId = '/uniqueId';
  static const main = '/main';
}

final getPages = [
  GetPage(
    name: Routes.splash,
    page: () => const SplashView(),
    binding: SplashBinding(),
  ),
  GetPage(
    name: Routes.login,
    page: () => const LoginView(),
    binding: LoginBinding(),
  ),
  GetPage(
    name: Routes.uniqueId,
    page: () => UniqueIdInputView(),
    binding: UniqueIdInputBinding(),
  ),

  GetPage(
    name: Routes.main,
    page: () => const BottomNavView(),
    binding: BottomNavBinding(),
  ),
];
