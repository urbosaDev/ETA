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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final naverMap = FlutterNaverMap();
  await naverMap.init(
    clientId: dotenv.env['NAVER_CLIENT_ID'] ?? '',
    onAuthFailed: (ex) {
      print('❌ 네이버맵 인증 오류: $ex');
    },
  );

  DependencyInjection.init();
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
