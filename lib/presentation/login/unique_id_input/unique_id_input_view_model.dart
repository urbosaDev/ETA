import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';
import 'package:what_is_your_eta/presentation/core/filter_words.dart';

enum UniqueIdCheck { none, available, notAvailable, blank }

class UniqueIdInputViewModel extends GetxController {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  UniqueIdInputViewModel({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  }) : _authRepository = authRepository,
       _userRepository = userRepository;

  final name = ''.obs;
  final selectedName = ''.obs;
  final RxBool isNameValid = false.obs;

  final isCreated = false.obs;

  final RxBool isLoading = false.obs;

  final selectedId = ''.obs;
  final uniqueId = ''.obs;
  final RxBool isUniqueIdValid = false.obs;
  void resetUniqueId() {
    uniqueId.value = '';
    selectedId.value = '';
    isUniqueIdValid.value = false;
    uniqueIdCheck.value = UniqueIdCheck.none;
  }

  final RxBool isChecked = false.obs;

  void resetName() {
    name.value = '';
    selectedName.value = '';
    isNameValid.value = false;
  }

  final RxBool isCheckLoading = false.obs;
  final uniqueIdCheck = UniqueIdCheck.none.obs;

  void onUniqueIdChanged(String value) {
    uniqueId.value = value;
    uniqueIdCheck.value = UniqueIdCheck.none;
    isUniqueIdValid.value = isValidUniqueIdFormat(value);
    selectedId.value = '';
  }

  bool isValidUniqueIdFormat(String id) {
    final trimmed = id.trim();
    if (trimmed.length < 8 || trimmed.length > 12) return false;

    final regex = RegExp(r'^[a-z][a-z0-9]{7,11}$');
    if (!regex.hasMatch(trimmed)) return false;

    final lowered = trimmed.toLowerCase();
    const reservedWords = ['unknown', 'system', 'admin'];

    for (final word in reservedWords) {
      if (lowered == word) return false;
    }

    return true;
  }

  final RxString systemMessage = ''.obs;

  final RxBool shouldClearIdInput = false.obs;

  Future<void> checkUniqueId(String id) async {
    isCheckLoading.value = true;
    final trimmedId = id.trim();
    final lowered = trimmedId.toLowerCase();

    if (trimmedId.isEmpty) {
      uniqueIdCheck.value = UniqueIdCheck.blank;
      isLoading.value = false;

      return;
    }
    if (FilterWords.containsBlockedWord(trimmedId.toLowerCase())) {
      systemMessage.value = '⚠️ 아이디에 부적절한 단어가 포함되어 있습니다.';
      uniqueIdCheck.value = UniqueIdCheck.none;
      isCheckLoading.value = false;
      shouldClearIdInput.value = true;
      resetUniqueId();
      return;
    }
    const reservedWords = ['unknown', 'system', 'admin'];
    if (reservedWords.contains(lowered)) {
      systemMessage.value = '⚠️ 해당 아이디는 사용할 수 없습니다.';
      uniqueIdCheck.value = UniqueIdCheck.none;
      isCheckLoading.value = false;
      shouldClearIdInput.value = true;
      resetUniqueId();
      return;
    }
    try {
      final available = await _userRepository.isUniqueIdAvailable(trimmedId);
      if (available) {
        uniqueIdCheck.value = UniqueIdCheck.available;
        selectedId.value = trimmedId;
      } else {
        uniqueIdCheck.value = UniqueIdCheck.notAvailable;
        shouldClearIdInput.value = true;
        resetUniqueId();
      }
    } catch (_) {
      uniqueIdCheck.value = UniqueIdCheck.none;
      systemMessage.value = '아이디 중복 확인 중 오류가 발생했습니다.';
      shouldClearIdInput.value = true;
      resetUniqueId();
    } finally {
      isCheckLoading.value = false;
    }
  }

  final RxBool shouldClearNameInput = false.obs;
  void validateNameAndCheckFiltering(String nameInput) {
    final trimmedName = nameInput.trim();

    if (trimmedName.length < 2 || trimmedName.length > 10) {
      systemMessage.value = '⚠️ 별명은 2자 이상 10자 이하로 입력해주세요.';
      isNameValid.value = false;
      shouldClearNameInput.value = true;
      resetName();
      return;
    }

    final lower = trimmedName.toLowerCase();
    if (FilterWords.containsBlockedWord(lower)) {
      systemMessage.value = '⚠️ 별명에 부적절한 단어가 포함되어 있습니다.';
      isNameValid.value = false;
      shouldClearNameInput.value = true;
      resetName();
      return;
    }

    selectedName.value = trimmedName;
    isNameValid.value = true;
    return;
  }

  void onCreationHandled() {
    isCreated.value = false;
  }

  Future<void> createUser() async {
    isLoading.value = true;

    final user = _authRepository.getCurrentUser();
    final id = selectedId.value.trim();
    final nameValue = name.value.trim();

    if (user == null) {
      systemMessage.value = '로그인 상태가 아닙니다';
      isLoading.value = false;
      return;
    }

    final userModel = UserModel(
      uid: user.uid,
      uniqueId: id,
      name: nameValue,
      photoUrl: user.photoURL ?? dotenv.env['DEFAULT_IMAGE']!,
    );

    try {
      await _userRepository.createUser(userModel);
      isCreated.value = await _userRepository.userExists(userModel.uid);
    } catch (e) {
      isCreated.value = false;
      systemMessage.value = '사용자 생성에 실패했습니다';
    } finally {
      isLoading.value = false;
    }
  }
}
