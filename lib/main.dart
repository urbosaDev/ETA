import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/route_manager.dart';
import 'package:what_is_your_eta/core/dependency/dependency_unjection.dart';
import 'package:what_is_your_eta/firebase_options.dart';
import 'package:what_is_your_eta/routes/app_routes.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('✅ 백그라운드 메시지 수신: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
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
