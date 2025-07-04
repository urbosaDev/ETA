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

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Row(
              children: [
                GestureDetector(
                  onTap: onUserTap,
                  child: CircleAvatar(
                    radius: 12,
                    backgroundImage: NetworkImage(sender!.photoUrl),
                  ),
                ),
                const SizedBox(width: 4),
                Text(sender!.name, style: const TextStyle(fontSize: 12)),
              ],
            ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isMe ? Colors.blueAccent : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              msg.text,
              style: TextStyle(color: isMe ? Colors.white : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemBubble() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Text(
          msg.text,
          style: const TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _buildLocationBubble() {
    if (sender == null) return const SizedBox();

    final locationMsg = msg as LocationMessageModel;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth:
              MediaQueryData.fromView(
                WidgetsBinding.instance.window,
              ).size.width *
              0.7, // 💥 화면 70% 제한
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color:
              isMe ? Colors.blueAccent.withOpacity(0.8) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // 프로필
            if (!isMe)
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundImage: NetworkImage(sender!.photoUrl),
                  ),
                  const SizedBox(width: 4),
                  Text(sender!.name, style: const TextStyle(fontSize: 12)),
                ],
              ),
            const SizedBox(height: 8),

            // 공유 텍스트
            Text(
              '${sender!.name}님이 현재 위치를 공유하셨습니다.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isMe ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),

            // 주소
            Text(
              '주소: ${locationMsg.location.address}',
              style: TextStyle(
                fontSize: 13,
                color: isMe ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 2),

            // 거리 (text 필드에 "거리: ~m" 포함됨 → 그대로 사용)
            Text(
              locationMsg.text, // ex: '위치공유 (주소, 거리: 7.4 m)'
              style: TextStyle(
                fontSize: 13,
                color: isMe ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 2),

            // 시간
            Text(
              '시간: ${_formatDateTime(locationMsg.sentAt)}',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: isMe ? Colors.white60 : Colors.black54,
              ),
            ),
            const SizedBox(height: 8),

            // NaverMap
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
    );
  }
}

String _formatDateTime(DateTime dateTime) {
  return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
      '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
}
