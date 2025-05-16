import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/route_manager.dart';
import 'package:what_is_your_eta/presentation/splash/splash_view_model.dart';

class SplashView extends GetView<SplashViewModel> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.microtask(() {
          if (controller.isLoggedIn.value) {
            Get.offNamed('/home');
          } else {
            Get.offNamed('/login');
          }
        });
      });

      return const Scaffold(
        body: Center(child: Text('Welcome to What is your ETA!')),
      );
    });
  }
}
