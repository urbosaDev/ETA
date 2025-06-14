import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:what_is_your_eta/presentation/bottomNav/%08home/home_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/bottom_nav_view_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/profile/profile_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/setting/setting_view.dart';

class BottomNavView extends GetView<BottomNavViewModel> {
  const BottomNavView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final index = controller.currentIndex.value;

      return Scaffold(
        body: IndexedStack(
          index: index,
          children: [HomeView(), ProfileView(), SettingView()],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: index,
          onTap: controller.changeIndex,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_people_rounded),
              label: '프로필',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
          ],
        ),
      );
    });
  }
}
