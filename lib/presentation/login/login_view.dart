import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:what_is_your_eta/presentation/core/loading/common_loading_lottie.dart';
import 'package:what_is_your_eta/presentation/login/login_view_model.dart';
import 'package:what_is_your_eta/presentation/login/unique_id_input/unique_id_input_binding.dart';
import 'package:what_is_your_eta/presentation/login/unique_id_input/unique_id_input_view.dart';

class LoginView extends GetView<LoginViewModel> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    const maxContentWidth = 320.0;

    return Obx(() {
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
        });
        controller.idExist.value = null;
        return Center(child: CommonLoadingLottie());
      }
      if (controller.isLoading.value) {
        return Center(child: CommonLoadingLottie());
      }
      return Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxContentWidth),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.08),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: height * 0.08),
                  const Text(
                    'Login',
                    style: TextStyle(
                      fontFamily: 'Inconsolata',
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: height * 0.05),
                  const Text(
                    '친구들과 약속을 만들고\n위치를 공유해요!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'NotoSansKR',
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: height * 0.04),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        controller.signInWithGoogle();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Goog1e로 로그인',
                        style: TextStyle(
                          fontFamily: 'Inconsolata',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.03),
                  const Text(
                    '로그인 또는 회원가입을 하시면\n개인정보 처리방침에 동의하게 됩니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'NotoSansKR',
                      fontSize: 12,
                      color: Colors.white38,
                    ),
                  ),
                  SizedBox(height: height * 0.08),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
