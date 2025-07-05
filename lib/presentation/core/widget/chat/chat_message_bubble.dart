import 'package:flutter/material.dart';

import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:what_is_your_eta/data/model/message_model.dart';

import 'package:what_is_your_eta/data/model/user_model.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel msg;
  final bool isMe;
  final UserModel? sender; // nullable로 변경
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
    switch (msg.type) {
      case MessageType.text:
        return _buildTextBubble();
      case MessageType.system:
        return _buildSystemBubble(); // sender 없어도 됨
      case MessageType.location:
        return _buildLocationBubble();
    }
  }

  Widget _buildTextBubble() {
    if (sender == null) return const SizedBox();

    final bubbleColor =
        isMe
            ? const Color(0xFF333333).withOpacity(0.95) // 내가 보낸 메시지 (더 진하게)
            : const Color(0xFF222222).withOpacity(0.75);

    final textColor = Colors.white;

    final screenWidth =
        MediaQueryData.fromView(WidgetsBinding.instance.window).size.width;
    final maxWidth = screenWidth * 0.7;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          /// ❌ isMe일 때는 프로필, 닉네임 없이 말풍선만
          if (!isMe) ...[
            GestureDetector(
              onTap: onUserTap,
              child: CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(sender!.photoUrl),
              ),
            ),
            const SizedBox(width: 8),
          ],

          /// 채팅 내용 (isMe에 따라 이름/프로필 포함 여부 달라짐)
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
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.all(12),
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    msg.text,
                    style: TextStyle(
                      fontSize: 14,
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

  Widget _buildSystemBubble() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Center(
        child: Text(
          msg.text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _buildLocationBubble() {
    if (sender == null) return const SizedBox();

    final locationMsg = msg as LocationMessageModel;
    final maxWidth =
        MediaQueryData.fromView(WidgetsBinding.instance.window).size.width *
        0.8;

    return Align(
      alignment: Alignment.center,
      child: Column(
        children: [
          Text(
            '${sender!.name}님이 현재 위치를 공유하셨습니다.',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white30),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const SizedBox(height: 4),
                Text(
                  '주소: ${locationMsg.location.address}',
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
                const SizedBox(height: 2),
                Text(
                  locationMsg.text,
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
                const SizedBox(height: 2),
                Text(
                  '시간: ${_formatDateTime(locationMsg.sentAt)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.white60,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 150,
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
                      onMapReady: (controller) async {
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
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
