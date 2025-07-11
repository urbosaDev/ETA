import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sign_in_button/sign_in_button.dart';

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
        final exist = controller.idExist.value!;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (exist) {
            Get.offNamed('/main');
          } else {
            Get.to(
              () => UniqueIdInputView(),
              binding: UniqueIdInputBinding(),
            )?.then((_) {
              controller.idExist.value = null;
              controller.isLoading.value = false;
            });
          }
        });

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

                  SignInButton(
                    Buttons.google,
                    text: "Google 계정으로 로그인",
                    onPressed: () {
                      controller.signInWithGoogle();
                    },
                  ),
                  const SizedBox(height: 8),
                  SignInButton(
                    Buttons.apple,
                    text: "Apple로 로그인",
                    onPressed: () {
                      controller.signInWithApple();
                    },
                  ),

                  SizedBox(height: height * 0.03),
                  _buildPolicyText(context),
                  SizedBox(height: height * 0.08),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildPolicyText(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Text.rich(
      TextSpan(
        text: '로그인 또는 회원가입을 하시면\n',
        style: textTheme.bodySmall?.copyWith(
          color: Colors.white38,
          height: 1.5,
        ),
        children: [
          TextSpan(
            text: '개인정보 처리방침',
            style: textTheme.bodySmall?.copyWith(
              color: Colors.white38,
              fontWeight: FontWeight.bold,
            ),
            recognizer:
                TapGestureRecognizer()
                  ..onTap = () {
                    Get.toNamed('/privacy-policy');
                  },
          ),
          TextSpan(
            text: '에 동의하게 됩니다.',
            style: textTheme.bodySmall?.copyWith(color: Colors.white38),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
