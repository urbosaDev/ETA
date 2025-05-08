import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ChatService {
  // 채팅방 관련
  Future<String> create(Map<String, dynamic> data);
  Future<Map<String, dynamic>?> get(String roomId);
  Stream<Map<String, dynamic>> stream(String roomId);
  Future<void> update(String roomId, Map<String, dynamic> data);
  Future<void> delete(String roomId);

  // ✅ 메시지 관련 (JSON 기준)
  Future<void> sendMessageJson(String roomId, Map<String, dynamic> json);
  Stream<List<Map<String, dynamic>>> streamMessagesJson(String roomId);
}

class GroupChatService implements ChatService {
  final _ref = FirebaseFirestore.instance.collection('groupChatRooms');

  @override
  Future<String> create(Map<String, dynamic> data) async {
    final doc = _ref.doc();
    await doc.set({...data, 'id': doc.id});
    return doc.id;
  }

  @override
  Future<Map<String, dynamic>?> get(String roomId) async {
    final doc = await _ref.doc(roomId).get();
    return doc.data();
  }

  @override
  Stream<Map<String, dynamic>> stream(String roomId) {
    return _ref.doc(roomId).snapshots().map((doc) => doc.data()!);
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
  Future<void> sendMessageJson(String roomId, Map<String, dynamic> json) async {
    final messagesRef = _ref.doc(roomId).collection('messages');
    final newDoc = messagesRef.doc();
    await newDoc.set({...json, 'id': newDoc.id});
  }

  @override
  Stream<List<Map<String, dynamic>>> streamMessagesJson(String roomId) {
    return _ref
        .doc(roomId)
        .collection('messages')
        .orderBy('sentAt')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}

class PromiseChatService implements ChatService {
  final _ref = FirebaseFirestore.instance.collection('promiseChatRooms');

  @override
  Future<String> create(Map<String, dynamic> data) async {
    final docRef = _ref.doc();
    await docRef.set({...data, 'id': docRef.id});
    return docRef.id;
  }

  @override
  Future<Map<String, dynamic>?> get(String roomId) async {
    final doc = await _ref.doc(roomId).get();
    return doc.data();
  }

  @override
  Stream<Map<String, dynamic>> stream(String roomId) {
    return _ref.doc(roomId).snapshots().map((doc) => doc.data()!);
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
  Future<void> sendMessageJson(String roomId, Map<String, dynamic> json) async {
    final msgRef = _ref.doc(roomId).collection('messages');
    final newDoc = msgRef.doc();
    await newDoc.set({...json, 'id': newDoc.id});
  }

  @override
  Stream<List<Map<String, dynamic>>> streamMessagesJson(String roomId) {
    return _ref
        .doc(roomId)
        .collection('messages')
        .orderBy('sentAt')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((d) => d.data()).toList());
  }
}

class PrivateChatService implements ChatService {
  final _ref = FirebaseFirestore.instance.collection('privateChatRooms');

  @override
  Future<String> create(Map<String, dynamic> data) async {
    final docRef = _ref.doc();
    await docRef.set({...data, 'id': docRef.id});
    return docRef.id;
  }

  @override
  Future<Map<String, dynamic>?> get(String roomId) async {
    final doc = await _ref.doc(roomId).get();
    return doc.data();
  }

  @override
  Stream<Map<String, dynamic>> stream(String roomId) {
    return _ref.doc(roomId).snapshots().map((doc) => doc.data()!);
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
  Future<void> sendMessageJson(String roomId, Map<String, dynamic> json) async {
    final msgRef = _ref.doc(roomId).collection('messages');
    final newDoc = msgRef.doc();
    await newDoc.set({...json, 'id': newDoc.id});
  }

  @override
  Stream<List<Map<String, dynamic>>> streamMessagesJson(String roomId) {
    return _ref
        .doc(roomId)
        .collection('messages')
        .orderBy('sentAt')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((d) => d.data()).toList());
  }
}
