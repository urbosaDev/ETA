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

  final RxBool _isUniqueIdAvailable = false.obs;
  final RxBool _isCreated = false.obs;
  final RxString _name = ''.obs;
  final RxBool _isButtonEnabled = false.obs;

  bool get isUniqueIdAvailable => _isUniqueIdAvailable.value;
  bool get isCreated => _isCreated.value;
  bool get isButtonEnabled => _isButtonEnabled.value;
  String get name => _name.value;

  set name(String value) {
    _name.value = value;
    _updateButtonState();
  }

  String? errorMessage;

  void _updateButtonState() {
    _isButtonEnabled.value =
        _isUniqueIdAvailable.value && _name.value.trim().isNotEmpty;
  }

  Future<void> checkUniqueId(String uniqueId) async {
    _isUniqueIdAvailable.value = false;

    if (uniqueId.trim().isEmpty) {
      errorMessage = '아이디를 입력해주세요';
      _updateButtonState();
      return;
    }

    try {
      _isUniqueIdAvailable.value = await _userRepository.isUniqueIdAvailable(
        uniqueId,
      );
      errorMessage = null;
    } catch (e) {
      _isUniqueIdAvailable.value = false;
      errorMessage = '중복 확인 중 오류 발생';
    }
    _updateButtonState();
  }

  Future<void> createUser(String uniqueId) async {
    final user = _authRepository.getCurrentUser();
    if (user == null) {
      errorMessage = '로그인 상태가 아닙니다';
      return;
    }

    final userModel = UserModel(
      uid: user.uid,
      uniqueId: uniqueId,
      name: _name.value,
      photoUrl: user.photoURL ?? '',
    );

    try {
      await _userRepository.createUser(userModel);
      _isCreated.value = await _userRepository.userExists(userModel.uid);
    } catch (e) {
      _isCreated.value = false;
      errorMessage = '사용자 생성에 실패했습니다';
    }
  }
}
