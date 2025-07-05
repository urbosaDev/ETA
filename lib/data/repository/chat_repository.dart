import 'package:what_is_your_eta/data/model/message_model.dart';
import 'package:what_is_your_eta/data/service/chat_service.dart';

// 의존성 주입시 어떤 Chat을 사용할지에 따라 ChatService가 다르게 주입
abstract class ChatRepository {
  // 채팅방
  Future<String> createChatRoom({
    required String chatId,
    required Map<String, dynamic> data,
  });
  Future<Map<String, dynamic>?> getChatRoom(String roomId);

  Future<void> updateChatRoom(String roomId, Map<String, dynamic> data);
  Future<void> deleteChatRoom(String roomId);
  Future<bool> chatRoomExists(String roomId);
  // 메시지
  Future<void> sendMessage(String roomId, MessageModel message);

  /// 더 불러오기
  Future<List<MessageWithSnapshot>> fetchInitialMessageDocs(String roomId);
  Future<List<MessageWithSnapshot>> fetchMoreMessageDocs(
    String roomId,
    MessageWithSnapshot lastMessage,
  );
  Stream<List<MessageWithSnapshot>> streamLatestMessages(String roomId);
}

class ChatRepositoryImpl implements ChatRepository {
  final ChatService _service;

  ChatRepositoryImpl(this._service);

  // 채팅방 관련
  @override
  Future<String> createChatRoom({
    required String chatId,
    required Map<String, dynamic> data,
  }) {
    return _service.create(data, customId: chatId);
  }

  @override
  Future<Map<String, dynamic>?> getChatRoom(String roomId) {
    return _service.get(roomId);
  }

  @override
  Future<void> updateChatRoom(String roomId, Map<String, dynamic> data) {
    return _service.update(roomId, data);
  }

  @override
  Future<void> deleteChatRoom(String roomId) {
    return _service.delete(roomId);
  }

  @override
  Future<bool> chatRoomExists(String roomId) {
    return _service.exists(roomId); // 어떤 서비스든 연결은 동일
  }

  // 메시지 관련
  @override
  Future<void> sendMessage(String roomId, MessageModel message) {
    return _service.sendMessageJson(roomId, message.toJson());
  }

  @override
  Future<List<MessageWithSnapshot>> fetchInitialMessageDocs(
    String roomId,
  ) async {
    final docs = await _service.fetchInitialMessageDocs(roomId);
    return docs
        .map(
          (doc) => MessageWithSnapshot(
            model: MessageModel.fromJson(doc.data()! as Map<String, dynamic>),
            snapshot: doc,
          ),
        )
        .toList();
  }

  @override
  Future<List<MessageWithSnapshot>> fetchMoreMessageDocs(
    String roomId,
    MessageWithSnapshot lastMessage,
  ) async {
    final docs = await _service.fetchMoreMessagesAfterDoc(
      roomId,
      lastMessage.getSnapshot(),
    );
    return docs
        .map(
          (doc) => MessageWithSnapshot(
            model: MessageModel.fromJson(doc.data()! as Map<String, dynamic>),
            snapshot: doc,
          ),
        )
        .toList();
  }

  @override
  Stream<List<MessageWithSnapshot>> streamLatestMessages(String roomId) {
    return _service
        .streamLatestMessages(roomId)
        .map(
          (docs) =>
              docs
                  .map(
                    (doc) => MessageWithSnapshot(
                      model: MessageModel.fromJson(
                        doc.data()! as Map<String, dynamic>,
                      ),
                      snapshot: doc,
                    ),
                  )
                  .toList(),
        );
  }
}
