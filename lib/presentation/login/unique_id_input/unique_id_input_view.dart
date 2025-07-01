import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/presentation/login/unique_id_input/unique_id_input_view_model.dart';

//
class UniqueIdInputView extends GetView<UniqueIdInputViewModel> {
  UniqueIdInputView({super.key});

  final textIdController = TextEditingController();
  final textNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('아이디 설정')),
      body: Obx(() {
        return Stack(
          children: [
            if (controller.isLoading.value)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(child: CircularProgressIndicator()),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUniqueIdInput(),
                    const SizedBox(height: 8),
                    _buildUniqueIdStatusText(),
                    const SizedBox(height: 8),
                    _buildUniqueIdButtons(),
                    const SizedBox(height: 16),
                    _buildSelectedIdText(),
                    _buildNameInput(),
                    const SizedBox(height: 24),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildUniqueIdInput() {
    return TextField(
      controller: textIdController,
      onChanged: controller.onUniqueIdChanged,
      decoration: const InputDecoration(labelText: '아이디 입력'),
    );
  }

  Widget _buildUniqueIdStatusText() {
    return Obx(() {
      switch (controller.uniqueIdCheck.value) {
        case UniqueIdCheck.available:
          return const Text('✅ 사용 가능한 아이디입니다.');
        case UniqueIdCheck.notAvailable:
          return const Text('❌ 이미 사용 중인 아이디입니다.');
        case UniqueIdCheck.blank:
          return const Text('⚠️ 아이디를 입력해주세요.');
        default:
          return const SizedBox.shrink();
      }
    });
  }

  Widget _buildUniqueIdButtons() {
    return Obx(() {
      return Row(
        children: [
          ElevatedButton(
            onPressed:
                () => controller.checkUniqueId(controller.uniqueId.value),
            child: const Text('중복 확인'),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed:
                controller.uniqueIdCheck.value == UniqueIdCheck.available
                    ? () =>
                        controller.selectedId.value = controller.uniqueId.value
                    : null,
            child: const Text('확정'),
          ),
        ],
      );
    });
  }

  Widget _buildSelectedIdText() {
    return Obx(() {
      if (controller.selectedId.value.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            '✔ 확정된 아이디: ${controller.selectedId.value}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  Widget _buildNameInput() {
    return TextField(
      controller: textNameController,
      decoration: const InputDecoration(labelText: '이름 입력'),
      onChanged: (val) => controller.name.value = val,
    );
  }

  Widget _buildSubmitButton() {
    return Obx(() {
      return ElevatedButton(
        onPressed:
            controller.isFormValid
                ? () async {
                  await controller.createUser();
                  if (controller.isCreated.value) {
                    Get.offAllNamed('/main');
                  } else if (controller.errorMessage.isNotEmpty) {
                    Get.snackbar('오류', controller.errorMessage.value);
                  }
                }
                : null,
        child: const Text('아이디 생성하기'),
      );
    });
  }
}
