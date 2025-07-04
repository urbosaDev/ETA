import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/message_model.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/chat_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';

import 'package:what_is_your_eta/presentation/bottomNav/%08home/private_chat/private_chat_room/private_chat_room_view_model.dart';
import 'package:what_is_your_eta/presentation/core/widget/chat/chat_input_box.dart';
import 'package:what_is_your_eta/presentation/core/widget/chat/chat_message_bubble.dart';

import 'package:what_is_your_eta/presentation/user_profile/user_profile_view.dart';
import 'package:what_is_your_eta/presentation/user_profile/user_profile_view_model.dart';

class PrivateChatRoomView extends GetView<PrivateChatRoomViewModel> {
  PrivateChatRoomView({super.key}) {
    scrollController.addListener(_onScroll);
  }

  final ScrollController scrollController = ScrollController();
  final TextEditingController messageController = TextEditingController();

  void _onScroll() {
    if (!scrollController.hasClients) return;

    const threshold = 100.0;
    final position = scrollController.position;

    final isAtTop = position.pixels >= position.maxScrollExtent - threshold;

    if (isAtTop && !controller.isLoadingMore.value) {
      controller.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    ever(controller.shouldScrollToBottom, (bool shouldScroll) {
      if (shouldScroll && scrollController.hasClients) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollController.jumpTo(scrollController.position.minScrollExtent);
          controller.shouldScrollToBottom.value = false;
        });
      }
    });
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Obx(() {
          final friend = controller.friendModel.value;
          if (friend == null) return const Text('로딩 중...');

          return Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Get.offAllNamed('/main');
                },
              ),
              const SizedBox(width: 8),
              CircleAvatar(backgroundImage: NetworkImage(friend.photoUrl)),
              const SizedBox(width: 8),
              Text(friend.name),
            ],
          );
        }),
      ),
      body: Column(
        children: [
          Obx(() {
            final friend = controller.friendModel.value;
            if (friend == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return Expanded(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Obx(() {
                  final msgs = controller.messages;
                  final friend = controller.friendModel.value;
                  if (friend == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final userMap = {
                    controller.myUid: controller.myModel.value!,
                    friend.uid: friend,
                  };

                  return Align(
                    alignment: Alignment.topCenter,
                    child: CustomScrollView(
                      shrinkWrap: true,
                      reverse: true,
                      controller: scrollController,
                      slivers: [
                        SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final msg = msgs[index];
                            final isMe = msg.senderId == controller.myUid;
                            final sender =
                                msg.type == MessageType.system
                                    ? null
                                    : userMap[msg.senderId];

                            if (sender == null &&
                                msg.type != MessageType.system) {
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
                                        userRepository:
                                            Get.find<UserRepository>(),
                                        authRepository:
                                            Get.find<AuthRepository>(),
                                        chatRepository:
                                            Get.find<ChatRepository>(),
                                        targetUserUid: sender!.uid,
                                      ),
                                    );
                                  }),
                                );
                              },
                            );
                          }, childCount: msgs.length),
                        ),
                        Obx(() {
                          return controller.isLoadingMore.value
                              ? SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              )
                              : const SliverToBoxAdapter(child: SizedBox());
                        }),
                      ],
                    ),
                  );
                }),
              ),
            );
          }),
          ChatInputBox(
            controller: messageController,
            onSend: (value) async {
              FocusScope.of(context).unfocus();
              await controller.sendMessage(value);
              messageController.clear();
            },
          ),
        ],
      ),
    );
  }
}
