import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/route_manager.dart';
import 'package:what_is_your_eta/presentation/login/unique_id_input/unique_id_input_binding.dart';
import 'package:what_is_your_eta/presentation/login/unique_id_input/unique_id_input_view.dart';
import 'package:what_is_your_eta/presentation/splash/splash_view_model.dart';

class SplashView extends GetView<SplashViewModel> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (controller.authStatus.value) {
        case AuthStatus.notLoggedIn:
          Future.microtask(() => Get.offNamed('/login'));
          break;
        case AuthStatus.needsProfile:
          Future.microtask(
            () => Get.off(
              () => UniqueIdInputView(),
              binding: UniqueIdInputBinding(),
            ),
          );
          break;
        case AuthStatus.loggedIn:
          Future.microtask(() => Get.offNamed('/main'));
          break;
        default:
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
      }
      return Scaffold(body: Center(child: Text('Splash')));
    });
  }
}
