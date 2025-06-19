import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FcmTokenService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> saveFcmToken() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final token = await _messaging.getToken();
    if (token == null) return;

    final userDocRef = _firestore.collection('users').doc(user.uid);

    await userDocRef.set({
      'fcmTokens': FieldValue.arrayUnion([token]),
    }, SetOptions(merge: true));

    print('FCM Token 저장됨 (Array): $token');
  }

  Future<void> deleteFcmToken() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final token = await _messaging.getToken();
    if (token == null) return;

    final userDocRef = _firestore.collection('users').doc(user.uid);

    await userDocRef.update({
      'fcmTokens': FieldValue.arrayRemove([token]),
    });

    print('FCM Token 삭제됨 (Array): $token');
  }

  // FCM Token refresh 대응 → app 실행 시 listen 등록
  void listenTokenRefresh() {
    _messaging.onTokenRefresh.listen((newToken) async {
      final user = _auth.currentUser;
      if (user == null) return;

      final userDocRef = _firestore.collection('users').doc(user.uid);

      await userDocRef.set({
        'fcmTokens': FieldValue.arrayUnion([newToken]),
      }, SetOptions(merge: true));

      print('FCM Token 갱신됨 (Array): $newToken');
    });
  }
}
