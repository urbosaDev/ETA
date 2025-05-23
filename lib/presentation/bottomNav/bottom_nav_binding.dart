import 'package:get/get.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/chat_repository.dart';
import 'package:what_is_your_eta/data/repository/group_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/create_group/create_group_view_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/group_view_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/home_view_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/private_chat/%08add_friend/add_friend_view_model.dart';

import 'package:what_is_your_eta/presentation/bottomNav/%08home/private_chat/private_chat_view_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/bottom_nav_view_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/notification/notification_view_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/setting/setting_view_model.dart';

class BottomNavBinding extends Bindings {
  @override
  void dependencies() {
    // ViewModels
    Get.put(BottomNavViewModel());
    Get.put(
      HomeViewModel(
        authRepository: Get.find<AuthRepository>(),
        userRepository: Get.find<UserRepository>(),
        groupRepository: Get.find<GroupRepository>(),
      ),
    );
    Get.put(SettingViewModel(authRepository: Get.find<AuthRepository>()));
    Get.put(NotificationViewModel());
    Get.put(
      PrivateChatViewModel(
        userRepository: Get.find<UserRepository>(),
        authRepository: Get.find<AuthRepository>(),
        chatRepository: Get.find<ChatRepository>(),
      ),
    );
    Get.put(AddFriendViewModel(userRepository: Get.find<UserRepository>()));
    Get.put(
      CreateGroupViewModel(
        userRepository: Get.find<UserRepository>(),
        authRepository: Get.find<AuthRepository>(),
        groupRepository: Get.find<GroupRepository>(),
      ),
    );
    Get.put(GroupViewModel());
  }
}
