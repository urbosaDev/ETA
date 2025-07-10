import 'package:firebase_auth/firebase_auth.dart';
import 'package:what_is_your_eta/data/service/auth_service.dart';

// FireAuth 관련된 것만 담당 , getCurrentUser는 FireAuth내의 정보만 다루기에
//  UserModel 말고 User 리턴
abstract class AuthRepository {
  Future<String?> signInWithGoogle();
  Future<String?> signInWithApple(); // Apple 로그인 메서드 추가
  Future<void> signOut();
  User? getCurrentUser(); // User 타입이 Firebase 종속적이긴 하지만, 현재 사용 중이라면 유지
  String? getCurrentUid();
  Future<void> deleteAccount();
  bool isSignedIn();
  Stream<User?> get userStream; // Firebase User 타입 스트림도 ViewModel에서 직접 사용한다면 유지
}

class FirebaseAuthRepository implements AuthRepository {
  final AuthService _authService; // 구체적인 AuthService에 의존

  FirebaseAuthRepository(this._authService);

  @override
  Future<String?> signInWithGoogle() async {
    final credential = await _authService.signInWithGoogle();
    return credential.user?.uid;
  }

  @override
  Future<String?> signInWithApple() async {
    // Apple 로그인 구현
    final credential = await _authService.signInWithApple();
    return credential.user?.uid;
  }

  @override
  Future<void> signOut() async {
    await _authService.signOut();
  }

  @override
  User? getCurrentUser() {
    return _authService.getCurrentUser();
  }

  @override
  String? getCurrentUid() => _authService.getCurrentUid();

  @override
  Future<void> deleteAccount() => _authService.deleteAccount();

  @override
  bool isSignedIn() => _authService.isSignedIn();

  @override
  Stream<User?> get userStream => _authService.userStream;
}
