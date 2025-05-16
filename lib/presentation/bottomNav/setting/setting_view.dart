import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/presentation/bottomNav/setting/setting_view_model.dart';

class SettingView extends GetView<SettingViewModel> {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setting')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            controller.signOut();
            Get.offNamed('/login');
          },
          child: const Text('Sign Out'),
        ),
      ),
    );
  }
}
