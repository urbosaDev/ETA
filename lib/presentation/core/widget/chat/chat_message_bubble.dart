import 'package:flutter/material.dart';

import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:what_is_your_eta/data/model/message_model.dart';

import 'package:what_is_your_eta/data/model/user_model.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel msg;
  final bool isMe;
  final UserModel? sender;
  final VoidCallback onUserTap;

  const MessageBubble({
    super.key,
    required this.msg,
    required this.isMe,
    required this.sender,
    required this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    switch (msg.type) {
      case MessageType.text:
        return _buildTextBubble(context, textTheme);
      case MessageType.system:
        return _buildSystemBubble(textTheme);
      case MessageType.location:
        return _buildLocationBubble(context, textTheme);
    }
  }

  Widget _buildTextBubble(BuildContext context, TextTheme textTheme) {
    if (sender == null && !isMe) return const SizedBox();

    final bubbleColor =
        isMe
            ? Theme.of(context).elevatedButtonTheme.style?.backgroundColor
                    ?.resolve({})
                    ?.withOpacity(0.9) ??
                Colors.pinkAccent.withOpacity(0.9)
            : const Color(0xFF222222).withOpacity(0.9);

    final textColor = Colors.white;

    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth * 0.75;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            GestureDetector(
              onTap: onUserTap,
              child: CircleAvatar(
                radius: 12,
                backgroundImage: NetworkImage(sender!.photoUrl),
                backgroundColor: Colors.grey[700],
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      sender!.name,
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.all(10),
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    msg.text,
                    style: textTheme.bodySmall?.copyWith(
                      color: textColor,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemBubble(TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Center(
        child: Text(
          msg.text,
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _buildLocationBubble(BuildContext context, TextTheme textTheme) {
    if (sender == null) return const SizedBox();

    final locationMsg = msg as LocationMessageModel;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth * 0.75;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  sender!.name,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
              ),
            Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    isMe
                        ? Theme.of(context)
                                .elevatedButtonTheme
                                .style
                                ?.backgroundColor
                                ?.resolve({})
                                ?.withOpacity(0.9) ??
                            Colors.pinkAccent.withOpacity(0.9)
                        : const Color(0xFF222222).withOpacity(0.9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${sender!.name}님이 현재 위치를 공유하셨습니다.',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '주소: ${locationMsg.location.address}',
                    style: textTheme.bodySmall?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    locationMsg.text,
                    style: textTheme.bodySmall?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '시간: ${_formatDateTime(locationMsg.sentAt)}',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      height: 120,
                      child: NaverMap(
                        options: NaverMapViewOptions(
                          initialCameraPosition: NCameraPosition(
                            target: NLatLng(
                              locationMsg.location.latitude,
                              locationMsg.location.longitude,
                            ),
                            zoom: 16,
                          ),
                          indoorEnable: false,
                          locationButtonEnable: false,
                          scaleBarEnable: false,
                        ),
                        onMapReady: (controller) {
                          final marker = NMarker(
                            id:
                                'location_marker_${DateTime.now().millisecondsSinceEpoch}',
                            position: NLatLng(
                              locationMsg.location.latitude,
                              locationMsg.location.longitude,
                            ),
                          );
                          controller.addOverlay(marker);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
