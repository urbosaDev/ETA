import 'package:what_is_your_eta/data/model/user_model.dart';

class ChatRoomDisplayModel {
  final String chatRoomId;
  final UserModel opponentUser;

  ChatRoomDisplayModel({required this.chatRoomId, required this.opponentUser});
}
