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

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print(' 백그라운드 메시지 수신: ${message.messageId}');
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

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void _printDeviceFCMToken() async {
  String? token = await FirebaseMessaging.instance.getToken();
  print('📱 Device FCM Token: $token');
}

void _setupTokenRefreshListener() {
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    print('🆕 FCM Token refreshed: $newToken');
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
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Background Handler 등록
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // iOS Permission 요청 (Android는 자동 허용됨)
  await _requestNotificationPermission();

  _setupTokenRefreshListener();
  final naverMap = FlutterNaverMap();
  await naverMap.init(
    clientId: dotenv.env['NAVER_CLIENT_ID'] ?? '',
    onAuthFailed: (ex) {
      print('❌ 네이버맵 인증 오류: $ex');
    },
  );

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
          backgroundColor: Color(0xff1a1a1a), // 바텀 네비게이션 배경색
          selectedItemColor: Colors.white, // 선택된 아이템 색상
          unselectedItemColor: Colors.white54, // 선택되지 않은 아이템 색상
          selectedLabelStyle: TextStyle(fontSize: 12), // 선택된 라벨 스타일
          unselectedLabelStyle: TextStyle(fontSize: 12), // 선택되지 않은 라벨 스타일
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
          indicatorColor: Colors.grey[800], // 선택된 탭의 배경 느낌
        ),

        scaffoldBackgroundColor: const Color(0xff111111), // 기본 배경색
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontFamily: 'NotoSansKR',
            fontSize: 17.0, // 충분히 큰 크기
            fontWeight: FontWeight.w700, // Bold (NotoSansKR-Bold.ttf)
            color: Colors.white, // 기본 색상
          ),

          bodyMedium: TextStyle(
            fontFamily: 'NotoSansKR',
            fontSize: 16.0, // 읽기 편한 본문 크기
            fontWeight: FontWeight.w400, // Regular (NotoSansKR-Regular.ttf)
            color: Colors.white, // 기본 색상
          ),

          bodySmall: TextStyle(
            fontFamily: 'NotoSansKR',
            fontSize: 12.0, // 작은 보조 텍스트 크기
            fontWeight: FontWeight.w400, // Regular
            color: Colors.white70, // 조금 연한 흰색 (보조적인 느낌)
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
