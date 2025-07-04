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

class ChatMessageListView extends StatefulWidget {
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
  State<ChatMessageListView> createState() => _ChatMessageListViewState();
}

class _ChatMessageListViewState extends State<ChatMessageListView> {
  final ScrollController _scrollController = ScrollController();
  final RxBool _showScrollToBottomButton = false.obs;

  bool _isUserAtBottom = true;

  void _scrollToBottom({bool force = false}) {
    if (!force && !_isUserAtBottom) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom(force: true);
    });

    widget.messages.listen((list) {
      if (list.isEmpty) return;
      final latestMsg = list.last;
      final isMe = latestMsg.senderId == widget.myUid;

      if (isMe || _isUserAtBottom) {
        _scrollToBottom(force: true);
      }
    });

    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;
      const threshold = 80.0;

      _isUserAtBottom = (maxScroll - currentScroll) <= threshold;
      _showScrollToBottomButton.value = !_isUserAtBottom;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Obx(() {
          final messages = widget.messages;
          return ListView.builder(
            controller: _scrollController,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final msg = messages[index];
              final isMe = msg.senderId == widget.myUid;
              final sender =
                  msg.type == MessageType.system
                      ? null
                      : widget.userMap[msg.senderId];

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
          );
        }),
        Obx(() {
          if (!_showScrollToBottomButton.value) return const SizedBox();
          return Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.grey.shade800,
              onPressed: () {
                _scrollToBottom(force: true);
              },
              child: const Icon(Icons.arrow_downward),
            ),
          );
        }),
      ],
    );
  }
}
