import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';

enum UniqueIdCheck { none, available, notAvailable, blank }

class UniqueIdInputViewModel extends GetxController {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  UniqueIdInputViewModel({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  }) : _authRepository = authRepository,
       _userRepository = userRepository;

  final uniqueId = ''.obs;
  final name = ''.obs;
  final uniqueIdCheck = UniqueIdCheck.none.obs;
  final selectedId = ''.obs;
  final isCreated = false.obs;
  final errorMessage = ''.obs;
  final isConfirmEnabled = false.obs;

  bool get isFormValid =>
      selectedId.value.isNotEmpty && name.value.trim().isNotEmpty;

  void onUniqueIdChanged(String value) {
    uniqueId.value = value;
    uniqueIdCheck.value = UniqueIdCheck.none;
    selectedId.value = '';
    isConfirmEnabled.value = false;
  }

  Future<void> checkUniqueId(String id) async {
    final trimmedId = id.trim();

    if (trimmedId.isEmpty) {
      uniqueIdCheck.value = UniqueIdCheck.blank;
      isConfirmEnabled.value = false;
      return;
    }

    // 금지 아이디 체크
    if (trimmedId.toLowerCase() == 'system') {
      uniqueIdCheck.value = UniqueIdCheck.notAvailable;
      isConfirmEnabled.value = false;
      selectedId.value = '';
      return;
    }

    try {
      final available = await _userRepository.isUniqueIdAvailable(trimmedId);
      uniqueIdCheck.value =
          available ? UniqueIdCheck.available : UniqueIdCheck.notAvailable;
      isConfirmEnabled.value = available;
      if (!available) selectedId.value = '';
    } catch (_) {
      uniqueIdCheck.value = UniqueIdCheck.none;
      isConfirmEnabled.value = false;
      selectedId.value = '';
    }
  }

  void confirmSelectedId() {
    selectedId.value = uniqueId.value;
  }

  Future<void> createUser() async {
    final user = _authRepository.getCurrentUser();
    if (user == null) {
      errorMessage.value = '로그인 상태가 아닙니다';
      return;
    }

    final userModel = UserModel(
      uid: user.uid,
      uniqueId: selectedId.value,
      name: name.value,
      photoUrl: user.photoURL ?? '',
    );

    try {
      await _userRepository.createUser(userModel);
      isCreated.value = await _userRepository.userExists(userModel.uid);
    } catch (e) {
      isCreated.value = false;
      errorMessage.value = '사용자 생성에 실패했습니다';
    }
  }
}
