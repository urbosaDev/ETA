import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/route_manager.dart';

import 'package:what_is_your_eta/presentation/splash/splash_view_model.dart';

class SplashView extends GetView<SplashViewModel> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.isCheckLogin.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          switch (controller.authStatus) {
            case AuthStatus.notLoggedIn:
            case AuthStatus.incompleteAccount:
              Get.offNamed('/login');
              break;
            case AuthStatus.loggedIn:
              Get.offNamed('/main');
              break;
            default:
              break;
          }
        });
      }
      return Scaffold(body: Center(child: Text('Splash')));
    });
  }
}
