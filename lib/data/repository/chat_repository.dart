import 'package:what_is_your_eta/data/model/message/message_model.dart';
import 'package:what_is_your_eta/data/service/chat_service.dart';

// 의존성 주입시 어떤 Chat을 사용할지에 따라 ChatService가 다르게 주입
abstract class ChatRepository {
  // 채팅방
  Future<String> createChatRoom(Map<String, dynamic> data);
  Future<Map<String, dynamic>?> getChatRoom(String roomId);
  Stream<Map<String, dynamic>> streamChatRoom(String roomId);
  Future<void> updateChatRoom(String roomId, Map<String, dynamic> data);
  Future<void> deleteChatRoom(String roomId);

  // 메시지
  Future<void> sendMessage(String roomId, MessageModel message);
  Stream<List<MessageModel>> streamMessages(String roomId);
}

class ChatRepositoryImpl implements ChatRepository {
  final ChatService _service;

  ChatRepositoryImpl(this._service);

  // 채팅방 관련
  @override
  Future<String> createChatRoom(Map<String, dynamic> data) {
    return _service.create(data);
  }

  @override
  Future<Map<String, dynamic>?> getChatRoom(String roomId) {
    return _service.get(roomId);
  }

  @override
  Stream<Map<String, dynamic>> streamChatRoom(String roomId) {
    return _service.stream(roomId);
  }

  @override
  Future<void> updateChatRoom(String roomId, Map<String, dynamic> data) {
    return _service.update(roomId, data);
  }

  @override
  Future<void> deleteChatRoom(String roomId) {
    return _service.delete(roomId);
  }

  // 메시지 관련
  @override
  Future<void> sendMessage(String roomId, MessageModel message) {
    return _service.sendMessageJson(roomId, message.toJson());
  }

  @override
  Stream<List<MessageModel>> streamMessages(String roomId) {
    return _service
        .streamMessagesJson(roomId)
        .map((jsonList) => jsonList.map(MessageModel.fromJson).toList());
  }
}
