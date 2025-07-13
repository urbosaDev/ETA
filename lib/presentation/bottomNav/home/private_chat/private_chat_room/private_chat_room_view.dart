import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/message_model.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/chat_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';
import 'package:what_is_your_eta/domain/usecase/get_single_with_status_usecase.dart';

import 'package:what_is_your_eta/presentation/bottomNav/%08home/private_chat/private_chat_room/private_chat_room_view_model.dart';
import 'package:what_is_your_eta/presentation/core/loading/common_loading_lottie.dart';
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
    final textTheme = Theme.of(context).textTheme;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.shouldScrollToBottom.value &&
          scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
        controller.shouldScrollToBottom.value = false;
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Obx(() {
          final friend = controller.friendModel.value;
          if (friend == null) {
            return Text('로딩 중...', style: textTheme.bodyMedium);
          }

          return Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Get.offNamed('/main');
                },
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(friend.photoUrl),
                backgroundColor: Colors.grey[700],
              ),
              const SizedBox(width: 8),
              Text(
                friend.name,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        }),
      ),
      body: Column(
        children: [
          Container(
            alignment: Alignment.topCenter,

            child: Text(
              '채팅에 오신 것을 환영합니다! 🎉\n이 채팅에서 발생하는 모든 부적절한 언행(욕설, 비방, 음란물, 개인정보 요구 등)은 서비스 이용 제한의 대상이 될 수 있습니다. 서로 존중하는 대화를 부탁드립니다.😊',
              style: textTheme.bodySmall?.copyWith(),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Obx(() {
                final msgs = controller.messages;
                final friend = controller.friendModel.value;
                if (friend == null) {
                  return const Center(child: CommonLoadingLottie());
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
                        delegate: SliverChildBuilderDelegate((context, index) {
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
                                      getSingleUserWithStatusUsecase:
                                          Get.find<
                                            GetSingleUserWithStatusUsecase
                                          >(),
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
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      textTheme.bodyMedium?.color ??
                                          Colors.white,
                                    ),
                                  ),
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
          ),
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
