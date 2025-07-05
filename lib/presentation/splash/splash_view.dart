import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/route_manager.dart';
import 'package:what_is_your_eta/presentation/core/loading/common_loading_lottie.dart';

import 'package:what_is_your_eta/presentation/splash/splash_view_model.dart';

class SplashView extends GetView<SplashViewModel> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

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

      return Scaffold(
        body: Stack(
          alignment: Alignment.center,
          children: [
            Visibility(
              visible: controller.isCheckLogin.value,
              child: const CommonLoadingLottie(),
            ),
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: width * 0.25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: Image.asset(
                        'assets/imgs/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: height * 0.12),

                    const Text(
                      'E.T.A',
                      style: TextStyle(
                        fontFamily: 'Inconsolata',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 4,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
