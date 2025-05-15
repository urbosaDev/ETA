import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';

class UniqueIdInputViewModel extends GetxController {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  UniqueIdInputViewModel({
    required UserRepository userRepository,
    required AuthRepository authRepository,
  }) : _authRepository = authRepository,
       _userRepository = userRepository;

  final _isUniqueIdAvailable = false.obs;
  bool get isUniqueIdAvailable => _isUniqueIdAvailable.value;

  Future<void> checkUniqueId(String uniqueId) async {
    _isUniqueIdAvailable.value = false;

    if (uniqueId.trim().isEmpty) {
      Get.snackbar('오류', '아이디를 입력해주세요');
      return;
    }
    try {
      _isUniqueIdAvailable.value = await _userRepository.isUniqueIdAvailable(
        uniqueId,
      );
    } catch (e) {
      _isUniqueIdAvailable.value = false;
    }
  }

  final _isCreated = false.obs;
  bool get isCreated => _isCreated.value;
  Future<void> createUser(String uniqueId, String name) async {
    final user = _authRepository.getCurrentUser();
    if (user == null) {
      Get.snackbar('오류', '로그인 상태가 아닙니다');
      return;
    }
    final userModel = UserModel(
      uid: user.uid,
      uniqueId: uniqueId,
      name: name,
      photoUrl: user.photoURL ?? '',
    );
    try {
      await _userRepository.createUser(userModel);
      _isCreated.value = await _userRepository.userExists(userModel.uid);
    } catch (e) {
      _isCreated.value = false;
      Get.snackbar('오류', '사용자 생성에 실패했습니다');
    }
  }
}
