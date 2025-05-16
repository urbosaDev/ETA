import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// 구글 로그인
  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google 로그인 취소됨');
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  }

  /// 로그아웃
  Future<void> signOut() async {
    await _googleSignIn.signOut(); // Google 로그아웃
    await _auth.signOut(); // Firebase 로그아웃
  }

  /// 현재 유저 가져오기
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// 현재 UID 가져오기
  String? getCurrentUid() {
    return _auth.currentUser?.uid;
  }

  /// 계정 삭제
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('로그인된 유저 없음');
    await user.delete();
  }

  /// 로그인 여부 확인
  bool isSignedIn() {
    return _auth.currentUser != null;
  }

  Stream<User?> get userStream => _auth.authStateChanges();
}
