import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/message_model.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/chat_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/lounge_in_group/lounge_in_group_view_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/promise_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/promise_view_model.dart';
import 'package:what_is_your_eta/presentation/core/widget/chat/chat_input_box.dart';
import 'package:what_is_your_eta/presentation/core/widget/chat/chat_message_bubble.dart';
import 'package:what_is_your_eta/presentation/user_profile/user_profile_view.dart';
import 'package:what_is_your_eta/presentation/user_profile/user_profile_view_model.dart';

class LoungeInGroupView extends GetView<LoungeInGroupViewModel> {
  LoungeInGroupView({super.key}) {
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
      backgroundColor: Color(0xff111111),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Color(0xff111111),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Color(0xFFA8216B).withOpacity(0.7),
          ),
          onPressed: () {
            Get.back();
          },
        ),
        actions: [
          Obx(() {
            final textTheme =
                Theme.of(context).textTheme; // TextTheme 인스턴스 가져오기
            final promiseId = controller.currentPromiseId.value;
            final isEnabled = promiseId != null;

            return Padding(
              padding: const EdgeInsets.only(right: 12.0), // 오른쪽 패딩 유지
              child: TextButton(
                onPressed:
                    isEnabled
                        ? () {
                          Get.to(
                            () => PromiseView(),
                            binding: BindingsBuilder(() {
                              Get.put(PromiseViewModel(promiseId: promiseId));
                            }),
                          );
                        }
                        : null,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  isEnabled ? "약속 보기" : "약속 없음",
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color:
                        isEnabled
                            ? Color(0xFFA8216B).withOpacity(0.7)
                            : Colors.grey[600],
                  ),
                ),
              ),
            );
          }),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Color(0xFFA8216B).withOpacity(0.5), // 원하는 divider 색상
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            alignment: Alignment.topCenter,
            child: Text(
              '그룹에 오신 것을 환영합니다! 🎉\n이 채팅에서 발생하는 모든 부적절한 언행(욕설, 비방, 음란물, 개인정보 요구 등)은 서비스 이용 제한의 대상이 될 수 있습니다. 서로 존중하는 대화를 부탁드립니다.😊',
              style: textTheme.bodySmall?.copyWith(),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Obx(() {
                final msgs = controller.messages;

                if (controller.memberMap.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

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
                          final isMe =
                              msg.senderId == controller.userModel.value?.uid;
                          final sender =
                              msg.type == MessageType.system
                                  ? null
                                  : controller.memberMap[msg.senderId];

                          if (sender == null &&
                              msg.type != MessageType.system) {
                            return const SizedBox();
                          }
                          if (controller.blockedUidsList.contains(
                            msg.senderId,
                          )) {
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
