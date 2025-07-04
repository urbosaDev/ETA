import 'package:cloud_firestore/cloud_firestore.dart';
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

  /// 초기 메시지 (20개 + DocumentSnapshot 목록)
  Future<List<DocumentSnapshot>> fetchInitialMessageDocs(String roomId);

  /// 더 불러오기
  Future<List<DocumentSnapshot>> fetchMoreMessageDocs(
    String roomId,
    DocumentSnapshot lastDoc,
  );

  /// 실시간 스트리밍 (마지막 메시지 이후)
  Stream<List<DocumentSnapshot>> streamLatestMessages(String roomId);

  /// helper (보통 ViewModel에서 호출)
  List<MessageModel> convertDocsToMessages(List<DocumentSnapshot> docs);
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
  Future<List<DocumentSnapshot>> fetchInitialMessageDocs(String roomId) {
    return _service.fetchInitialMessageDocs(roomId);
  }

  @override
  Future<List<DocumentSnapshot>> fetchMoreMessageDocs(
    String roomId,
    DocumentSnapshot lastDoc,
  ) {
    return _service.fetchMoreMessagesAfterDoc(roomId, lastDoc);
  }

  @override
  Stream<List<DocumentSnapshot>> streamLatestMessages(String roomId) {
    return _service.streamLatestMessages(roomId);
  }

  @override
  List<MessageModel> convertDocsToMessages(List<DocumentSnapshot> docs) {
    return docs
        .map(
          (doc) => MessageModel.fromJson(doc.data()! as Map<String, dynamic>),
        )
        .toList();
  }
}
