import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/chat_repository.dart';
import 'package:what_is_your_eta/data/repository/fcm_repository.dart';
import 'package:what_is_your_eta/data/repository/group_repository.dart';
import 'package:what_is_your_eta/data/repository/location_repository.dart';
import 'package:what_is_your_eta/data/repository/promise_repository.dart';
import 'package:what_is_your_eta/data/repository/fcm_token_repository.dart';

import 'package:what_is_your_eta/data/repository/user_%08repository.dart';
import 'package:what_is_your_eta/data/service/auth_service.dart';
import 'package:what_is_your_eta/data/service/chat_service.dart';
import 'package:what_is_your_eta/data/service/fcm_service.dart';
import 'package:what_is_your_eta/data/service/fcm_token_service.dart';

import 'package:what_is_your_eta/data/service/group_service.dart';
import 'package:what_is_your_eta/data/service/local_map_api_service.dart';

import 'package:what_is_your_eta/data/service/promise_service.dart';
import 'package:what_is_your_eta/data/service/user_service.dart';

class DependencyInjection {
  static Future<void> init() async {
    final kakaoApiKey = dotenv.env['KAKAO_REST_API_KEY']!;
    final kakaoBaseUrl = dotenv.env['KAKAO_BASE_URL']!;
    final fcmFunctionUrl = dotenv.env['FIREBASE_FCM_FUNCTION_URL']!;
    final fcmService = FcmService(functionUrl: fcmFunctionUrl);

    Get.put<FcmService>(fcmService, permanent: true);
    Get.put<AuthService>(AuthService(), permanent: true);
    Get.put<UserService>(UserService(), permanent: true);
    Get.put<GroupService>(GroupService(), permanent: true);

    Get.put<PrivateChatService>(PrivateChatService(), permanent: true);
    Get.put<GroupChatService>(GroupChatService(), permanent: true);
    Get.put<PromiseChatService>(PromiseChatService(), permanent: true);

    Get.put<FcmRepository>(
      FcmRepositoryImpl(fcmService: Get.find<FcmService>()),
      permanent: true,
    );

    Get.put<FcmTokenService>(FcmTokenService(), permanent: true);
    Get.put<FcmTokenRepository>(
      FcmTokenRepository(service: Get.find<FcmTokenService>()),
      permanent: true,
    );

    Get.put<LocalMapApiService>(
      KakaoMapLocalApiService(
        client: http.Client(),
        baseUrl: kakaoBaseUrl,
        apiKey: kakaoApiKey,
      ),
      permanent: true,
    );
    Get.put<PromiseService>(PromiseService(), permanent: true);

    Get.put<GroupRepository>(
      GroupRepositoryImpl(Get.find<GroupService>()),
      permanent: true,
    );
    Get.put<AuthRepository>(
      FirebaseAuthRepository(Get.find<AuthService>()),
      permanent: true,
    );
    Get.put<UserRepository>(
      UserRepositoryImpl(Get.find<UserService>()),
      permanent: true,
    );

    Get.put<ChatRepository>(
      ChatRepositoryImpl(Get.find<PrivateChatService>()),
      permanent: true,
    );
    Get.put<LocationRepository>(
      LocationRepositoryImpl(apiService: Get.find<LocalMapApiService>()),
      permanent: true,
    );
    Get.put<PromiseRepository>(
      PromiseRepositoryImpl(Get.find<PromiseService>()),
      permanent: true,
    );
  }
}
