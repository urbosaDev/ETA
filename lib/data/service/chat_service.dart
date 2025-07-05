import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ChatService {
  // 채팅방 관련
  Future<String> create(Map<String, dynamic> data, {String? customId});
  Future<Map<String, dynamic>?> get(String roomId);
  Future<void> update(String roomId, Map<String, dynamic> data);
  Future<void> delete(String roomId);
  Future<bool> exists(String roomId);

  // 메시지 관련
  Future<void> sendMessageJson(String roomId, Map<String, dynamic> json);
  Future<List<DocumentSnapshot>> fetchInitialMessageDocs(String roomId);
  Future<List<DocumentSnapshot>> fetchMoreMessagesAfterDoc(
    String roomId,
    DocumentSnapshot lastDoc,
  );
  Stream<List<DocumentSnapshot>> streamLatestMessages(String roomId);
}

class PrivateChatService implements ChatService {
  final _ref = FirebaseFirestore.instance.collection('privateChatRooms');

  @override
  Future<String> create(Map<String, dynamic> data, {String? customId}) async {
    final docRef = customId != null ? _ref.doc(customId) : _ref.doc();
    await docRef.set({...data, 'id': docRef.id});
    return docRef.id;
  }

  @override
  Future<Map<String, dynamic>?> get(String roomId) async {
    final doc = await _ref.doc(roomId).get();
    return doc.data();
  }

  @override
  Future<void> update(String roomId, Map<String, dynamic> data) async {
    await _ref.doc(roomId).update(data);
  }

  @override
  Future<void> delete(String roomId) async {
    await _ref.doc(roomId).delete();
  }

  @override
  Future<bool> exists(String roomId) async {
    final doc = await _ref.doc(roomId).get();
    return doc.exists;
  }

  @override
  Future<void> sendMessageJson(String roomId, Map<String, dynamic> json) async {
    final msgRef = _ref.doc(roomId).collection('messages');
    final newDoc = msgRef.doc();
    await newDoc.set({...json, 'id': newDoc.id});
  }

  @override
  Future<List<DocumentSnapshot>> fetchInitialMessageDocs(String roomId) async {
    final snapshot =
        await _ref
            .doc(roomId)
            .collection('messages')
            .orderBy('sentAt', descending: true)
            .limit(20)
            .get();
    return snapshot.docs;
  }

  /// 다음 페이지 메시지
  @override
  Future<List<DocumentSnapshot>> fetchMoreMessagesAfterDoc(
    String roomId,
    DocumentSnapshot lastDoc,
  ) async {
    final snapshot =
        await _ref
            .doc(roomId)
            .collection('messages')
            .orderBy('sentAt', descending: true)
            .startAfterDocument(lastDoc)
            .limit(20)
            .get();
    return snapshot.docs;
  }

  /// 새로운 메시지 실시간 스트리밍
  @override
  Stream<List<DocumentSnapshot>> streamLatestMessages(String roomId) {
    return _ref
        .doc(roomId)
        .collection('messages')
        .orderBy('sentAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }
}
