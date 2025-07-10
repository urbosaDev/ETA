import 'package:what_is_your_eta/data/model/private_chat_model.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';

class ChatRoomDisplayModel {
  final PrivateChatModel chatRoom;
  final UserModel opponentUser;

  ChatRoomDisplayModel({required this.chatRoom, required this.opponentUser});
}
