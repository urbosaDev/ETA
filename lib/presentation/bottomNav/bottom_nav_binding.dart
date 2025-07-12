import 'package:get/get.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/chat_repository.dart';
import 'package:what_is_your_eta/data/repository/notification_client_repository.dart';
import 'package:what_is_your_eta/data/repository/group_repository.dart';

import 'package:what_is_your_eta/data/repository/user_%08repository.dart';
import 'package:what_is_your_eta/domain/usecase/get_friends_with_status_usecase.dart';

import 'package:what_is_your_eta/presentation/bottomNav/%08home/home_view_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/private_chat/%08add_friend/add_friend_view_model.dart';

import 'package:what_is_your_eta/presentation/bottomNav/%08home/private_chat/private_chat_view_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/bottom_nav_view_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/notification/notification_view_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/setting/setting_view_model.dart';

class BottomNavBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(
      BottomNavViewModel(
        fcmTokenRepository: Get.find<NotificationClientRepository>(),
      ),
    );
    Get.put(
      HomeViewModel(
        authRepository: Get.find<AuthRepository>(),
        userRepository: Get.find<UserRepository>(),
        groupRepository: Get.find<GroupRepository>(),
      ),
    );
    Get.put(
      SettingViewModel(
        authRepository: Get.find<AuthRepository>(),
        fcmTokenRepository: Get.find<NotificationClientRepository>(),
        userRepository: Get.find<UserRepository>(),
      ),
    );

    Get.put(
      PrivateChatViewModel(
        userRepository: Get.find<UserRepository>(),
        authRepository: Get.find<AuthRepository>(),
        chatRepository: Get.find<ChatRepository>(),
        getFriendsWithStatusUsecase: Get.find<GetFriendsWithStatusUsecase>(),
      ),
    );
    Get.put(AddFriendViewModel(userRepository: Get.find<UserRepository>()));

    Get.put(
      NotificationViewModel(
        userRepository: Get.find<UserRepository>(),
        authRepository: Get.find<AuthRepository>(),
        groupRepository: Get.find<GroupRepository>(),
      ),
    );
  }
}
