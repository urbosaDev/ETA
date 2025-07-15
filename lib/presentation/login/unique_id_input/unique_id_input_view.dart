import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/presentation/bottomNav/setting/privacy_policy_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/setting/terms_of_service_view.dart';
import 'package:what_is_your_eta/presentation/core/loading/common_loading_lottie.dart';
import 'package:what_is_your_eta/presentation/core/widget/common_text_field.dart';

import 'package:what_is_your_eta/presentation/login/unique_id_input/unique_id_input_view_model.dart';

//
class UniqueIdInputView extends GetView<UniqueIdInputViewModel> {
  UniqueIdInputView({super.key});

  final textIdController = TextEditingController();
  final textNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textTheme = Theme.of(context).textTheme;

    final horizontalPadding = screenWidth * 0.05;
    final verticalPadding = screenHeight * 0.08;

    return Obx(() {
      final isLoading = controller.isLoading.value;
      final message = controller.systemMessage.value;
      final clearIdInput = controller.shouldClearIdInput.value;
      final clearNameInput = controller.shouldClearNameInput.value;
      final toNavigate = controller.isCreated.value;

      if (isLoading) {
        return const Center(child: CommonLoadingLottie());
      }

      if (message.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.snackbar('알림', message, snackPosition: SnackPosition.TOP);
          controller.systemMessage.value = '';
        });
      }
      if (clearIdInput) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          textIdController.clear();
          controller.shouldClearIdInput.value = false;
        });
      }
      if (clearNameInput) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          textNameController.clear();
          controller.shouldClearNameInput.value = false;
        });
      }
      if (toNavigate) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offNamed('/main');
          controller.isCreated.value = false;
        });
      }

      return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            Scaffold(
              appBar: AppBar(),
              body: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(textTheme),
                    const SizedBox(height: 8),
                    _buildIdHeader(textTheme),
                    _buildUniqueIdInput(),
                    _buildIdFormatStatus(textTheme),
                    const SizedBox(height: 8),
                    _buildUniqueIdStatusText(textTheme),
                    const SizedBox(height: 8),
                    Center(child: _buildUniqueIdButtons()),
                    const SizedBox(height: 16),
                    _buildeNameHeader(textTheme),
                    _buildNameInput(),
                    _buildNameStatusText(textTheme),
                    Center(child: _buildNameCheckButtons()),
                    _buildTermsAgreement(textTheme),
                    Center(child: _buildSubmitButton()),
                    Text(
                      '⚠️  부적절한 단어(욕설, 사회적으로 부적절한 표현 등)가 포함될 경우 제재를 받을 수 있습니다.',
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (controller.isCheckLoading.value)
              IgnorePointer(
                ignoring: true,
                child: Container(
                  color: Colors.black.withOpacity(0.6),
                  child: const Center(child: CommonLoadingLottie()),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildHeader(TextTheme textTheme) {
    return Text('아이디와 별명을 입력해주세요', style: textTheme.titleLarge);
  }

  Widget _buildIdHeader(TextTheme textTheme) {
    return Row(
      children: [
        Text(
          '앱에서 사용할 아이디를 입력해주세요',
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        Obx(() {
          return Checkbox(
            value: controller.selectedId.value.isNotEmpty,
            onChanged: null,
            checkColor: Colors.greenAccent,
          );
        }),
      ],
    );
  }

  Widget _buildeNameHeader(TextTheme textTheme) {
    return Row(
      children: [
        Text(
          '앱에서 사용할 별명을 입력해주세요',
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        Obx(() {
          return Checkbox(
            value: controller.selectedName.isNotEmpty,
            onChanged: null,
            checkColor: Colors.greenAccent,
          );
        }),
      ],
    );
  }

  Widget _buildIdFormatStatus(TextTheme textTheme) {
    return Obx(() {
      if (controller.uniqueId.value.isEmpty) {
        return Text(
          '아이디는 영어소문자와 숫자로 구성된 8~12자여야 합니다.',
          style: textTheme.bodySmall,
        );
      }

      if (controller.isUniqueIdValid.value) {
        return Text(
          '✅ 사용 가능한 아이디 형식입니다. \n중복 확인을 눌러주세요.',
          style: textTheme.bodySmall?.copyWith(color: Colors.green),
        );
      } else {
        return Text(
          '❌ 아이디는 영어소문자와 숫자로 구성된 8~12자여야 합니다.',
          style: textTheme.bodySmall?.copyWith(color: Colors.redAccent),
        );
      }
    });
  }

  Widget _buildUniqueIdInput() {
    return CommonTextField(
      controller: textIdController,
      hintText: '아이디 입력',
      keyboardType: TextInputType.text,
      onChanged: (value) {
        controller.onUniqueIdChanged(value);
      },
      maxLength: 12,
    );
  }

  Widget _buildUniqueIdStatusText(TextTheme textTheme) {
    return Obx(() {
      switch (controller.uniqueIdCheck.value) {
        case UniqueIdCheck.available:
          return Text(
            '✅ 사용 가능한 아이디입니다.',
            style: textTheme.bodySmall?.copyWith(color: Colors.green),
          );
        case UniqueIdCheck.notAvailable:
          return Text(
            '❌ 이미 사용 중인 아이디입니다.',
            style: textTheme.bodySmall?.copyWith(color: Colors.redAccent),
          );
        case UniqueIdCheck.blank:
          return Text(
            '⚠️ 아이디를 입력해주세요.',
            style: textTheme.bodySmall?.copyWith(color: Colors.orange),
          );
        default:
          return const SizedBox.shrink();
      }
    });
  }

  Widget _buildUniqueIdButtons() {
    return Obx(() {
      final isValid = controller.isUniqueIdValid.value;
      final isAlreadySelected = controller.selectedId.value.isNotEmpty;

      final isButtonEnabled = isValid && !isAlreadySelected;

      return ElevatedButton(
        onPressed:
            isButtonEnabled
                ? () => controller.checkUniqueId(controller.uniqueId.value)
                : () {},
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isButtonEnabled ? null : Colors.grey.withOpacity(0.4),
          foregroundColor: isButtonEnabled ? null : Colors.black38,
        ),
        child: const Text('중복 확인'),
      );
    });
  }

  Widget _buildNameInput() {
    return CommonTextField(
      controller: textNameController,
      hintText: '별명 입력',
      maxLength: 10,
      keyboardType: TextInputType.name,
      onChanged: (value) {
        controller.name.value = value.trim();
        controller.selectedName.value = '';
      },
    );
  }

  Widget _buildNameStatusText(TextTheme textTheme) {
    return Obx(() {
      final trimmed = controller.name.value.trim();
      if (trimmed.isEmpty)
        return Text(
          '⚠ 별명을 입력해주세요.',
          style: textTheme.bodySmall?.copyWith(color: Colors.orange),
        );
      if (trimmed.length < 2)
        return Text(
          '⚠ 별명은 최소 2자 이상입니다.',
          style: textTheme.bodySmall?.copyWith(color: Colors.orange),
        );
      if (trimmed.length > 10)
        return Text(
          '⚠ 별명은 최대 10자까지 입력 가능합니다.',
          style: textTheme.bodySmall?.copyWith(color: Colors.orange),
        );
      return const SizedBox.shrink();
    });
  }

  Widget _buildNameCheckButtons() {
    return Obx(() {
      final nameInput = controller.name.value;
      final isLengthValid = nameInput.length >= 2 && nameInput.length <= 10;
      final isAlreadySelected =
          controller.selectedName.value.isNotEmpty &&
          controller.isNameValid.value;
      return ElevatedButton(
        onPressed:
            isLengthValid && !isAlreadySelected
                ? () => controller.validateNameAndCheckFiltering(
                  controller.name.value,
                )
                : () {},
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isLengthValid && !isAlreadySelected
                  ? null
                  : Colors.grey.withOpacity(0.4),
          foregroundColor:
              isLengthValid && !isAlreadySelected ? null : Colors.black38,
        ),
        child: const Text('별명 확인'),
      );
    });
  }

  Widget _buildTermsAgreement(TextTheme textTheme) {
    return Row(
      children: [
        Checkbox(
          value: controller.isChecked.value,
          onChanged: (value) {
            controller.isChecked.value = value ?? false;
          },
        ),

        Expanded(
          child: RichText(
            text: TextSpan(
              style: textTheme.bodySmall?.copyWith(color: Colors.white70),
              children: [
                const TextSpan(text: '(필수) '),
                TextSpan(
                  text: '이용약관[보기]',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer:
                      TapGestureRecognizer()
                        ..onTap = () {
                          Get.to(
                            () => const TermsOfServiceView(),
                            transition: Transition.rightToLeft,
                          );
                        },
                ),
                const TextSpan(text: ' 및 '),
                TextSpan(
                  text: '개인정보처리방침[보기]',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer:
                      TapGestureRecognizer()
                        ..onTap = () {
                          Get.to(
                            () => const PrivacyPolicyView(),
                            transition: Transition.rightToLeft,
                          );
                        },
                ),
                const TextSpan(text: '에 모두 동의합니다.'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Obx(() {
      return ElevatedButton(
        onPressed:
            controller.isUniqueIdValid.value &&
                    controller.uniqueIdCheck.value == UniqueIdCheck.available &&
                    controller.isNameValid.value &&
                    controller.isChecked.value
                ? () async {
                  await controller.createUser();
                }
                : () {},
        style: ElevatedButton.styleFrom(
          backgroundColor:
              controller.isUniqueIdValid.value &&
                      controller.uniqueIdCheck.value ==
                          UniqueIdCheck.available &&
                      controller.isNameValid.value &&
                      controller.isChecked.value
                  ? null
                  : Colors.grey.withOpacity(0.4),
        ),
        child: const Text('아이디 생성하기'),
      );
    });
  }
}
