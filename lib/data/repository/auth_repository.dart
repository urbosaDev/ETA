import 'package:firebase_auth/firebase_auth.dart';
import 'package:what_is_your_eta/data/service/auth_service.dart';

// FireAuth 관련된 것만 담당 , getCurrentUser는 FireAuth내의 정보만 다루기에
//  UserModel 말고 User 리턴
abstract class AuthRepository {
  Future<String?> signInWithGoogle();
  Future<void> signOut();
  User? getCurrentUser();
  String? getCurrentUid();
  Future<void> deleteAccount();
  bool isSignedIn();
}

class FirebaseAuthRepository implements AuthRepository {
  final AuthService _authService;

  FirebaseAuthRepository(this._authService);

  @override
  Future<String?> signInWithGoogle() async {
    final credential = await _authService.signInWithGoogle();
    return credential.user?.uid;
  }

  @override
  Future<void> signOut() async {
    await _authService.signOut();
  }

  @override
  User? getCurrentUser() {
    final user = _authService.getCurrentUser();
    if (user == null) return null;

    return user;
  }

  @override
  String? getCurrentUid() => _authService.getCurrentUid();

  @override
  Future<void> deleteAccount() => _authService.deleteAccount();

  @override
  bool isSignedIn() => _authService.isSignedIn();
}
