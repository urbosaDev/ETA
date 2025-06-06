import 'package:get/get.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/chat_repository.dart';
import 'package:what_is_your_eta/data/repository/group_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';
import 'package:what_is_your_eta/data/service/auth_service.dart';
import 'package:what_is_your_eta/data/service/chat_service.dart';
import 'package:what_is_your_eta/data/service/group_service.dart';
import 'package:what_is_your_eta/data/service/user_service.dart';

class DependencyInjection {
  static void init() {
    Get.put<AuthService>(AuthService(), permanent: true);
    Get.put<UserService>(UserService(), permanent: true);
    Get.put<GroupService>(GroupService(), permanent: true);

    Get.put<PrivateChatService>(PrivateChatService(), permanent: true);
    Get.put<GroupChatService>(GroupChatService(), permanent: true);
    Get.put<PromiseChatService>(PromiseChatService(), permanent: true);

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
  }
}
