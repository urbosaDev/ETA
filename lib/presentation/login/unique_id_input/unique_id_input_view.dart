import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
                    const SizedBox(height: 24),
                    Center(child: _buildSubmitButton()),
                    Text(
                      '⚠️ 이름 또는 아이디에 부적절한 단어(욕설, 사회적으로 부적절한 표현 등)가 포함될 경우 제재를 받을 수 있습니다.',
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
    return Text('아이디와 이름을 입력해주세요', style: textTheme.titleLarge);
  }

  Widget _buildIdHeader(TextTheme textTheme) {
    return Row(
      children: [
        Text(
          '아이디를 입력해주세요',
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
          '이름을 입력해주세요',
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
          '아이디는 영문 소문자로 시작하고, \n숫자 포함가능 8~12자여야 합니다.',
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
          '❌ 아이디는 영문 소문자로 시작하고, \n숫자 포함가능 8~12자여야 합니다.',
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
      hintText: '이름 입력',
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
          '⚠ 이름을 입력해주세요.',
          style: textTheme.bodySmall?.copyWith(color: Colors.orange),
        );
      if (trimmed.length < 2)
        return Text(
          '⚠ 이름은 최소 2자 이상입니다.',
          style: textTheme.bodySmall?.copyWith(color: Colors.orange),
        );
      if (trimmed.length > 10)
        return Text(
          '⚠ 이름은 최대 10자까지 입력 가능합니다.',
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
        child: const Text('이름 확인'),
      );
    });
  }

  Widget _buildSubmitButton() {
    return Obx(() {
      return ElevatedButton(
        onPressed:
            controller.isUniqueIdValid.value &&
                    controller.uniqueIdCheck.value == UniqueIdCheck.available &&
                    controller.isNameValid.value
                ? () async {
                  await controller.createUser();
                }
                : () {},
        style: ElevatedButton.styleFrom(
          backgroundColor:
              controller.isUniqueIdValid.value &&
                      controller.uniqueIdCheck.value ==
                          UniqueIdCheck.available &&
                      controller.isNameValid.value
                  ? null
                  : Colors.grey.withOpacity(0.4),
        ),
        child: const Text('아이디 생성하기'),
      );
    });
  }
}
