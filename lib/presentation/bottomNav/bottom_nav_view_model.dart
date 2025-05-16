import 'package:get/state_manager.dart';

class BottomNavViewModel extends GetxController {
  final currentIndex = 0.obs;
  void changeIndex(int index) {
    currentIndex.value = index;
  }
}
