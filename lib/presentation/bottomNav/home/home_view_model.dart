import 'package:get/state_manager.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';

class HomeViewModel extends GetxController {
  final AuthRepository _authRepository;
  HomeViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository;

  Future<void> signOut() async {
    await _authRepository.signOut();
  }

  @override
  void onInit() {
    super.onInit();
  }
}
