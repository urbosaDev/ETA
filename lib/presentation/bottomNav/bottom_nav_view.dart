import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:what_is_your_eta/presentation/bottomNav/%08home/home_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/bottom_nav_view_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/notification/notification_view.dart';
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
          children: [HomeView(), NotificationView(), SettingView()],
        ),

        bottomNavigationBar: Material(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(height: 0.5, color: Colors.grey),
              BottomNavigationBar(
                currentIndex: index,
                onTap: controller.changeIndex,
                type: BottomNavigationBarType.fixed,
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.person), label: '홈'),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.notifications),
                    label: '알림',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings),
                    label: '설정',
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
