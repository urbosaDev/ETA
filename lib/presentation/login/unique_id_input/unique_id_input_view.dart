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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: textIdController,
                decoration: const InputDecoration(labelText: '아이디 입력'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed:
                    () => controller.checkUniqueId(textIdController.text),
                child: const Text('중복확인'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textNameController,
                decoration: const InputDecoration(labelText: '이름 입력'),
                onChanged: (val) => controller.name = val, // 수정됨
              ),
              const SizedBox(height: 8),
              controller.isUniqueIdAvailable
                  ? const Text('✅ 사용 가능한 아이디입니다.')
                  : const SizedBox.shrink(),
              const Spacer(),
              ElevatedButton(
                onPressed:
                    controller.isButtonEnabled
                        ? () async {
                          await controller.createUser(textIdController.text);
                          if (controller.isCreated) {
                            Get.offNamed('/main');
                          } else if (controller.errorMessage != null) {
                            Get.snackbar('오류', controller.errorMessage!);
                          }
                        }
                        : null,
                child: const Text('아이디 생성하기'),
              ),
            ],
          );
        }),
      ),
    );
  }
}
