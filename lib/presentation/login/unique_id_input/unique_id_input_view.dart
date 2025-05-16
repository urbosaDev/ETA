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
      body: Center(
        child: Obx(
          () => Column(
            children: [
              TextField(
                controller: textIdController,
                decoration: const InputDecoration(labelText: '아이디 입력'),
              ),
              ElevatedButton(
                onPressed: () async {
                  controller.checkUniqueId(textIdController.text);
                },
                child: Text('중복확인'),
              ),
              TextField(
                controller: textNameController,
                decoration: const InputDecoration(labelText: '이름 입력'),
              ),
              controller.isUniqueIdAvailable
                  ? const Text('사용 가능한 아이디입니다.')
                  : const Text(''),
              ElevatedButton(
                onPressed: () async {
                  controller.createUser(
                    textIdController.text,
                    textNameController.text,
                  );
                  if (controller.isCreated) {
                    Get.offNamed('/main');
                  }
                },
                child: Text('아이디 생성하기'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
