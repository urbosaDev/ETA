import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/presentation/login/login_view_model.dart';
import 'package:what_is_your_eta/presentation/login/unique_id_input/unique_id_input_binding.dart';
import 'package:what_is_your_eta/presentation/login/unique_id_input/unique_id_input_view.dart';

class LoginView extends GetView<LoginViewModel> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.systemMessage.isNotEmpty) {
        final msg = controller.systemMessage.value;
        controller.systemMessage.value = '';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.snackbar('알림', msg, snackPosition: SnackPosition.TOP);
        });
      }
      if (controller.idExist.value != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (controller.idExist.value == true) {
            Get.offNamed('/main');
          } else {
            Get.to(() => UniqueIdInputView(), binding: UniqueIdInputBinding());
          }
          controller.idExist.value = null;
        });
      }
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Login View'),
              ElevatedButton(
                onPressed: () async {
                  await controller.signInWithGoogle();
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
    });
  }
}
