import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/chat_repository.dart';
import 'package:what_is_your_eta/data/repository/notification_api_repository.dart';
import 'package:what_is_your_eta/data/repository/notification_client_repository.dart';
import 'package:what_is_your_eta/data/repository/group_repository.dart';
import 'package:what_is_your_eta/data/repository/location_repository.dart';
import 'package:what_is_your_eta/data/repository/promise_repository.dart';
import 'package:what_is_your_eta/data/repository/report_repository.dart';

import 'package:what_is_your_eta/data/repository/user_%08repository.dart';
import 'package:what_is_your_eta/data/service/auth_service.dart';
import 'package:what_is_your_eta/data/service/chat_service.dart';
import 'package:what_is_your_eta/data/service/notification_api_service.dart';
import 'package:what_is_your_eta/data/service/notification_client_service.dart';

import 'package:what_is_your_eta/data/service/group_service.dart';
import 'package:what_is_your_eta/data/service/local_map_api_service.dart';

import 'package:what_is_your_eta/data/service/promise_service.dart';
import 'package:what_is_your_eta/data/service/report_service.dart';
import 'package:what_is_your_eta/data/service/user_service.dart';
import 'package:what_is_your_eta/domain/usecase/calculate_distance_usecase.dart';
import 'package:what_is_your_eta/domain/usecase/get_friends_with_status_usecase.dart';
import 'package:what_is_your_eta/domain/usecase/get_single_with_status_usecase.dart';
import 'package:what_is_your_eta/presentation/network_controller.dart';

class DependencyInjection {
  static Future<void> init() async {
    final kakaoApiKey = dotenv.env['KAKAO_REST_API_KEY']!;
    final kakaoBaseUrl = dotenv.env['KAKAO_BASE_URL']!;
    final fcmFunctionUrl = dotenv.env['FIREBASE_FCM_FUNCTION_URL']!;
    final fcmService = NotificationApiService(functionUrl: fcmFunctionUrl);

    Get.put<NotificationApiService>(fcmService, permanent: true);
    Get.put<AuthService>(AuthService(), permanent: true);
    Get.put<UserService>(UserService(), permanent: true);
    Get.put<GroupService>(GroupService(), permanent: true);

    Get.put<PrivateChatService>(PrivateChatService(), permanent: true);

    Get.put<ReportService>(ReportService(), permanent: true);
    Get.put<NotificationApiRepository>(
      NotificationApiRepositoryImpl(
        fcmService: Get.find<NotificationApiService>(),
      ),
      permanent: true,
    );

    Get.put<NotificationClientService>(
      NotificationClientService(),
      permanent: true,
    );
    Get.put<NotificationClientRepository>(
      NotificationClientRepository(
        service: Get.find<NotificationClientService>(),
      ),
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
    Get.put<ReportRepository>(
      ReportRepositoryImpl(Get.find<ReportService>()),
      permanent: true,
    );
    Get.put<CalculateDistanceUseCase>(
      CalculateDistanceUseCase(),
      permanent: true,
    );
    Get.put<GetFriendsWithStatusUsecase>(
      GetFriendsWithStatusUsecase(
        authRepository: Get.find<AuthRepository>(),
        userRepository: Get.find<UserRepository>(),
      ),
      permanent: true,
    );
    Get.put<GetSingleUserWithStatusUsecase>(
      GetSingleUserWithStatusUsecase(
        authRepository: Get.find<AuthRepository>(),
        userRepository: Get.find<UserRepository>(),
      ),
      permanent: true,
    );
    Get.put<NetworkController>(NetworkController(), permanent: true);
  }
}
