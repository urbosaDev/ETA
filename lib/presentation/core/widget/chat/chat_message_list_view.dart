import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/chat_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';
import 'package:what_is_your_eta/presentation/user_profile/user_profile_view.dart';
import 'package:what_is_your_eta/presentation/user_profile/user_profile_view_model.dart';
import 'chat_message_bubble.dart';
import 'package:what_is_your_eta/data/model/message_model.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';

class ChatMessageListView extends StatelessWidget {
  final RxList<MessageModel> messages;
  final Map<String, UserModel> userMap;
  final String myUid;

  const ChatMessageListView({
    super.key,
    required this.messages,
    required this.userMap,
    required this.myUid,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final msg = messages[index];
          final isMe = msg.senderId == myUid;

          final sender =
              msg.type == MessageType.system ? null : userMap[msg.senderId];

          if (sender == null && msg.type != MessageType.system) {
            return const SizedBox();
          }

          return MessageBubble(
            msg: msg,
            isMe: isMe,
            sender: sender,
            onUserTap: () {
              Get.to(
                () => const UserProfileView(),
                fullscreenDialog: true,
                transition: Transition.downToUp,
                binding: BindingsBuilder(() {
                  Get.put(
                    UserProfileViewModel(
                      userRepository: Get.find<UserRepository>(),
                      authRepository: Get.find<AuthRepository>(),
                      chatRepository: Get.find<ChatRepository>(),
                      targetUserUid: sender!.uid,
                    ),
                  );
                }),
              );
            },
          );
        },
      ),
    );
  }
}
