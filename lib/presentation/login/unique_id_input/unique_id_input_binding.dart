import 'package:get/get.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';

import 'package:what_is_your_eta/presentation/login/unique_id_input/unique_id_input_view_model.dart';

class UniqueIdInputBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<UniqueIdInputViewModel>(
      UniqueIdInputViewModel(
        userRepository: Get.find<UserRepository>(),
        authRepository: Get.find<AuthRepository>(),
      ),
    );
  }
}
