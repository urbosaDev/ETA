import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

import 'package:get/route_manager.dart';
import 'package:what_is_your_eta/core/dependency/dependency_injection.dart';
import 'package:what_is_your_eta/firebase_options.dart';
import 'package:what_is_your_eta/routes/app_routes.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('✅ 백그라운드 메시지 수신: ${message.messageId}');
}

Future<void> _requestNotificationPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('🔔 User granted permission: ${settings.authorizationStatus}');
}

void _setupForegroundMessageListener() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('✅ 포그라운드 메시지 수신: ${message.messageId}');
    if (message.notification != null) {
      print(
        '📢 Notification: ${message.notification?.title} - ${message.notification?.body}',
      );
    }
  });
}

void _printDeviceFCMToken() async {
  String? token = await FirebaseMessaging.instance.getToken();
  print('📱 Device FCM Token: $token');
}

void _setupTokenRefreshListener() {
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    print('🆕 FCM Token refreshed: $newToken');
    // → 서버에 등록 필요 시 여기서 보내면 됨.
  });
}

void _setupApnsTokenDebug() async {
  try {
    final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    print('📲 APNs Token: $apnsToken');
  } catch (e) {
    print('❌ APNs Token error: $e');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Background Handler 등록
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 🔔 iOS Permission 요청 (Android는 자동 허용됨)
  await _requestNotificationPermission();

  // 🔔 Foreground 메시지 처리 등록
  _setupForegroundMessageListener();
  _setupTokenRefreshListener();
  final naverMap = FlutterNaverMap();
  await naverMap.init(
    clientId: dotenv.env['NAVER_CLIENT_ID'] ?? '',
    onAuthFailed: (ex) {
      print('❌ 네이버맵 인증 오류: $ex');
    },
  );

  DependencyInjection.init();
  _printDeviceFCMToken();
  _setupApnsTokenDebug();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'What is your ETA',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: Routes.splash,
      getPages: getPages,
    );
  }
}
