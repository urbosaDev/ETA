import 'package:flutter/material.dart';
import 'package:what_is_your_eta/data/model/message_model.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/presentation/core/widget/chat/chat_message_bubble.dart';

class ChatMessageListView extends StatelessWidget {
  final List<MessageModel> messages;
  final ScrollController scrollController;
  final Map<String, UserModel> userMap;
  final String myUid;
  final bool isLoadingMore;
  final void Function(UserModel sender) onUserTap;

  const ChatMessageListView({
    super.key,
    required this.messages,
    required this.scrollController,
    required this.userMap,
    required this.myUid,
    required this.isLoadingMore,
    required this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: CustomScrollView(
        reverse: true,
        controller: scrollController,
        slivers: [
          if (isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
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
                onUserTap: () => onUserTap(sender!),
              );
            }, childCount: messages.length),
          ),
        ],
      ),
    );
  }
}
