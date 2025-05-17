import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/home_view_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/private_chat/private_chat_view.dart';

class HomeView extends GetView<HomeViewModel> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Row(
        children: [
          SizedBox(
            width: 72,
            child: NavigationRail(
              selectedIndex: controller.selectedIndex,
              onDestinationSelected: controller.changeTab,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.chat),
                  label: Text('Chat'),
                ),

                NavigationRailDestination(
                  icon: Icon(Icons.add),
                  label: Text('Settings'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              switch (controller.selectedIndex) {
                case 0:
                  return const PrivateChatView(); // ✅ Chat 선택 시
                // case 1:
                //   return const SettingView(); // ✅ Settings 선택 시
                default:
                  return const Center(child: Text('선택된 뷰가 없습니다'));
              }
            }),
          ),
        ],
      ),
    );
  }
}
