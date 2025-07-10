import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

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

  Future<UserCredential> signInWithApple() async {
    // 1. Apple 로그인 credential 받기
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    // 2. Firebase Auth용 OAuth credential 생성
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    // 3. Firebase 로그인 처리
    return await _auth.signInWithCredential(oauthCredential);
  }

  /// 로그아웃
  Future<void> signOut() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      for (final userInfo in currentUser.providerData) {
        if (userInfo.providerId == GoogleAuthProvider.PROVIDER_ID) {
          await _googleSignIn.signOut();
        } else if (userInfo.providerId == AppleAuthProvider.PROVIDER_ID) {}
      }
    }
    await _auth.signOut();
  }

  /// 현재 유저 가져오기
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// 현재 UID 가져오기
  String? getCurrentUid() {
    return _auth.currentUser?.uid;
  }

  Future<void> deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('계정 삭제: 현재 로그인된 사용자가 없습니다.');
      throw Exception('로그인된 사용자가 없습니다.');
    }

    final providerId =
        user.providerData.isNotEmpty
            ? user.providerData.first.providerId
            : null;

    AuthCredential? reauthCredential;

    if (providerId == GoogleAuthProvider.PROVIDER_ID) {
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signInSilently();

      if (googleUser == null) {
        throw Exception('Google 재로그인이 필요합니다. 다시 시도해주세요.');
      }

      final googleAuth = await googleUser.authentication;
      reauthCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
    } else if (providerId == AppleAuthProvider.PROVIDER_ID) {
      try {
        final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );
        reauthCredential = OAuthProvider("apple.com").credential(
          idToken: appleCredential.identityToken,
          accessToken: appleCredential.authorizationCode,
        );
      } on Exception catch (e) {
        if (e.toString().contains('canceled')) {
          throw Exception('Apple 재인증이 취소되었습니다.');
        }
        throw Exception('Apple 재인증에 실패했습니다. 다시 시도해주세요: $e');
      }
    } else {
      throw Exception('계정 삭제를 위해 재인증이 필요합니다. 현재 로그인 방식은 직접 재인증을 지원하지 않습니다.');
    }

    if (reauthCredential != null) {
      try {
        await user.reauthenticateWithCredential(reauthCredential);
        await user.delete();
      } on Exception catch (e) {
        throw Exception('계정 삭제에 실패했습니다. 다시 로그인 후 시도해주세요: $e');
      }
    } else {
      throw Exception('재인증에 필요한 자격 증명을 얻지 못했습니다.');
    }
  }

  /// 로그인 여부 확인
  bool isSignedIn() {
    return _auth.currentUser != null;
  }

  Stream<User?> get userStream => _auth.authStateChanges();
}
