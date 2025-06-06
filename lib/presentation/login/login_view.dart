import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/presentation/login/login_view_model.dart';
import 'package:what_is_your_eta/presentation/login/unique_id_input/unique_id_input_binding.dart';
import 'package:what_is_your_eta/presentation/login/unique_id_input/unique_id_input_view.dart';

class LoginView extends GetView<LoginViewModel> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Login View'),
            ElevatedButton(
              onPressed: () async {
                final success = await controller.signInWithGoogle();
                if (!success) return; // 실패했으면 아무 화면 이동도 하지 않음

                controller.idExist
                    ? Get.offNamed('/main')
                    : Get.to(
                      () => UniqueIdInputView(),
                      binding: UniqueIdInputBinding(),
                    );
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
