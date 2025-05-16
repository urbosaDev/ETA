import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/homeSideNav/home_side_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/home_view_model.dart';

class HomeView extends GetView<HomeViewModel> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Row(
        children: [
          SizedBox(width: 72, child: HomeSideView()),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Home View'),
                ElevatedButton(
                  onPressed: () {
                    controller.signOut();
                    Get.offNamed('/login');
                  },
                  child: const Text('Logout'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
