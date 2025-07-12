import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationClientService {
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

  Future<void> subscribeToUserTopic(String userId) async {
    final topic = 'user_$userId';
    await _messaging.subscribeToTopic(topic);
    print('🔔 알림 구독 완료: $topic');
  }

  Future<void> unsubscribeFromUserTopic(String userId) async {
    final topic = 'user_$userId';
    await _messaging.unsubscribeFromTopic(topic);
    print('🔕 알림 구독 취소: $topic');
  }
}
