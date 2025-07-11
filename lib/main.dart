import 'package:flutter/foundation.dart'; // kDebugMode를 위해 필요
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

import 'package:get/route_manager.dart';
import 'package:what_is_your_eta/core/dependency/dependency_injection.dart';
import 'package:what_is_your_eta/firebase_options.dart';
import 'package:what_is_your_eta/routes/app_routes.dart';

void debugLog(String message) {
  if (kDebugMode) {
    print(message);
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugLog('백그라운드 메시지 수신: ${message.messageId}');
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

  debugLog(
    '🔔 User granted permission: ${settings.authorizationStatus}',
  ); // debugLog 사용
}

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void _printDeviceFCMToken() async {
  String? token = await FirebaseMessaging.instance.getToken();
  debugLog('📱 Device FCM Token: $token');
}

void _setupTokenRefreshListener() {
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    debugLog('🆕 FCM Token refreshed: $newToken');
  });
}

void _setupApnsTokenDebug() async {
  try {
    final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    debugLog('📲 APNs Token: $apnsToken');
  } catch (e) {
    debugLog('❌ APNs Token error: $e');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugLog('ERROR: Firebase initialization failed: $e');

    return;
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await _requestNotificationPermission();

  _setupTokenRefreshListener();

  final naverMap = FlutterNaverMap();
  try {
    await naverMap.init(
      clientId: dotenv.env['NAVER_CLIENT_ID'] ?? '',
      onAuthFailed: (ex) {
        debugLog('❌ 네이버맵 인증 오류: $ex');
      },
    );
  } catch (e) {
    debugLog('ERROR: NaverMap initialization failed: $e');
  }

  await DependencyInjection.init();

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
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xff1a1a1a),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white54,
          selectedLabelStyle: TextStyle(fontSize: 12),
          unselectedLabelStyle: TextStyle(fontSize: 12),
          showSelectedLabels: true,
          showUnselectedLabels: true,
        ),
        navigationRailTheme: NavigationRailThemeData(
          backgroundColor: const Color(0xff1a1a1a),
          selectedIconTheme: const IconThemeData(color: Colors.white),
          unselectedIconTheme: const IconThemeData(color: Colors.white54),
          selectedLabelTextStyle: const TextStyle(color: Colors.white),
          unselectedLabelTextStyle: const TextStyle(color: Colors.white54),
          elevation: 2,
          indicatorColor: Colors.grey[800],
        ),
        scaffoldBackgroundColor: const Color(0xff111111),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontFamily: 'NotoSansKR',
            fontSize: 17.0,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'NotoSansKR',
            fontSize: 16.0,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
          bodySmall: TextStyle(
            fontFamily: 'NotoSansKR',
            fontSize: 12.0,
            fontWeight: FontWeight.w400,
            color: Colors.white70,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xff111111),
          foregroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          hintStyle: TextStyle(color: Colors.white70),
          labelStyle: TextStyle(color: Colors.white),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFA8216B)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFA8216B), width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            backgroundColor: Colors.pinkAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            shadowColor: Colors.black.withOpacity(0.5),
            elevation: 5,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      initialRoute: Routes.splash,
      getPages: getPages,
    );
  }
}
