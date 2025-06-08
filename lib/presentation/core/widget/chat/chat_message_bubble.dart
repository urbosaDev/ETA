import 'package:flutter/material.dart';

import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:what_is_your_eta/data/model/message_model.dart';

import 'package:what_is_your_eta/data/model/user_model.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel msg;
  final bool isMe;
  final UserModel sender;

  const MessageBubble({
    super.key,
    required this.msg,
    required this.isMe,
    required this.sender,
  });

  @override
  Widget build(BuildContext context) {
    switch (msg.type) {
      case MessageType.text:
        return _buildTextBubble();
      case MessageType.system:
        return _buildSystemBubble();
      case MessageType.location:
        return _buildLocationBubble();
    }
  }

  Widget _buildTextBubble() {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundImage: NetworkImage(sender.photoUrl),
                ),
                const SizedBox(width: 4),
                Text(sender.name, style: const TextStyle(fontSize: 12)),
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
    final locationMsg = msg as LocationMessageModel;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundImage: NetworkImage(sender.photoUrl),
                ),
                const SizedBox(width: 4),
                Text(sender.name, style: const TextStyle(fontSize: 12)),
              ],
            ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            height: 200,
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
                  id: 'location_marker_${DateTime.now().millisecondsSinceEpoch}',
                  position: NLatLng(
                    locationMsg.location.latitude,
                    locationMsg.location.longitude,
                  ),
                );
                controller.addOverlay(marker);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              locationMsg.location.address,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isMe ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
