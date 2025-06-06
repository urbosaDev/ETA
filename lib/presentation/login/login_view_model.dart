import 'package:get/get.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';

// 로그인버튼 -> 로그인 화면으로 이동
// 1. 구글로그인
// 로그인 성공 후 uid로 Firestore에서 UserModel 존재 여부 확인
// 없다면 uniqueId를 입력받는 화면으로 이동
// 2. 구글로그인을 함으로서 UserModel 생성
// 3. UserModel을 통해서 FireStore에 저장
// 4. 이 과정이 끝나면 Home 화면으로 이동
class LoginViewModel extends GetxController {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  LoginViewModel({
    required UserRepository userRepository,
    required AuthRepository authRepository,
  }) : _userRepository = userRepository,
       _authRepository = authRepository;

  bool idExist = false;
  // 로그인 상태
  Future<bool> signInWithGoogle() async {
    try {
      final uid = await _authRepository.signInWithGoogle();
      if (uid == null) return false; // <- 여기!

      final user = _authRepository.getCurrentUser();
      if (user == null) throw Exception('User not found');

      idExist = await _userRepository.userExists(uid);
      return true;
    } catch (e) {
      return false; // 실패 시 false 반환
    }
  }
}
