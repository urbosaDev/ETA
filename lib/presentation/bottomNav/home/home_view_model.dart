import 'package:get/state_manager.dart';

class HomeViewModel extends GetxController {
  // 현재 선택된 탭 인덱스
  final RxInt _selectedIndex = 0.obs;
  int get selectedIndex => _selectedIndex.value;

  void changeTab(int index) {
    _selectedIndex.value = index;
  }
}
