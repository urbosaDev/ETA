import 'package:get/get.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';

class LoginViewModel extends GetxController {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  LoginViewModel({
    required UserRepository userRepository,
    required AuthRepository authRepository,
  }) : _userRepository = userRepository,
       _authRepository = authRepository;

  final RxnBool idExist = RxnBool();
  final RxBool isLoading = false.obs;
  final RxString systemMessage = ''.obs;

  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    try {
      final uid = await _authRepository.signInWithGoogle();
      if (uid == null) {
        systemMessage.value = '로그인 실패: 인증에 실패했습니다.\n 다시 시도해주세요.';
        isLoading.value = false;
        return;
      }

      final user = _authRepository.getCurrentUser();
      if (user == null) {
        systemMessage.value = '로그인 실패: 사용자 정보가 없습니다.\n 다시 시도해주세요.';
        isLoading.value = false;
        return;
      }
      final exist = await _userRepository.userExists(uid);
      idExist.value = exist;
    } catch (_) {
      systemMessage.value = '로그인 실패: 알 수 없는 오류가 발생했습니다.\n 다시 시도해주세요.';
      isLoading.value = false;
      return;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithApple() async {
    isLoading.value = true;
    try {
      final uid = await _authRepository.signInWithApple();
      if (uid == null) {
        systemMessage.value = '로그인 실패: 인증에 실패했습니다.\n 다시 시도해주세요.';
        isLoading.value = false;
        return;
      }

      final user = _authRepository.getCurrentUser();
      if (user == null) {
        systemMessage.value = '로그인 실패: 사용자 정보가 없습니다.\n 다시 시도해주세요.';
        isLoading.value = false;
        return;
      }
      final exist = await _userRepository.userExists(uid);
      idExist.value = exist;
    } catch (e) {
      systemMessage.value = '로그인 실패: 알 수 없는 오류가 발생했습니다.\n 다시 시도해주세요.';
      print('Error during Apple sign-in: $e');
      isLoading.value = false;
      return;
    } finally {
      isLoading.value = false;
    }
  }
}
