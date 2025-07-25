import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final CollectionReference<Map<String, dynamic>> _userRef = FirebaseFirestore
      .instance
      .collection('users');
  // 개인톡방이 생길때, 유저 채팅방정보 업데이트
  Future<void> addPrivateChatId(String uid, String chatRoomId) async {
    await _userRef.doc(uid).update({
      'privateChatIds': FieldValue.arrayUnion([chatRoomId]),
    });
  }

  Future<void> removePrivateChatId({
    required String uid,
    required String chatRoomId,
  }) async {
    await _userRef.doc(uid).update({
      'privateChatIds': FieldValue.arrayRemove([chatRoomId]),
    });
  }

  /// 최초 가입 시 사용
  Future<void> setUserData(String uid, Map<String, dynamic> data) async {
    await _userRef.doc(uid).set(data);
  }

  // 그룹 생성시, 유저 그룹리스트 업데이트용
  Future<void> addGroupId(String uid, String groupId) async {
    await _userRef.doc(uid).update({
      'groupIds': FieldValue.arrayUnion([groupId]),
    });
  }

  /// 부분 업데이트
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    await _userRef.doc(uid).update(data);
  }

  Future<void> addFriendUid(String currentUid, String friendUid) async {
    await _userRef.doc(currentUid).update({
      'friendsUids': FieldValue.arrayUnion([friendUid]),
    });
  }

  // 유저 차단
  Future<void> addBlockFriendUid({
    required String currentUid,
    required String blockFriendUid,
  }) async {
    await _userRef.doc(currentUid).update({
      'blockFriendsUids': FieldValue.arrayUnion([blockFriendUid]),
    });
  }

  //유저 차단 해제
  Future<void> removeBlockFriendUid({
    required String currentUid,
    required String blockFriendUid,
  }) async {
    await _userRef.doc(currentUid).update({
      'blockFriendsUids': FieldValue.arrayRemove([blockFriendUid]),
    });
  }

  /// 유저 조회
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _userRef.doc(uid).get();
    return doc.data();
  }

  /// 유저 스트리밍
  Stream<Map<String, dynamic>?> streamUserData(String uid) {
    return _userRef
        .doc(uid)
        .snapshots()
        .map((doc) => doc.data() as Map<String, dynamic>);
  }

  /// 삭제 (회원탈퇴)
  Future<void> deleteUser(String uid) async {
    await _userRef.doc(uid).delete();
  }

  /// 해당 UID 존재 여부
  Future<bool> userExists(String uid) async {
    final doc = await _userRef.doc(uid).get();
    return doc.exists;
  }

  /// 유저의 uniqueId (@dan123)로 UID 검색
  Future<String?> getUidByUniqueId(String uniqueId) async {
    final query =
        await _userRef.where('uniqueId', isEqualTo: uniqueId).limit(1).get();

    if (query.docs.isEmpty) return null;
    return query.docs.first.id;
  }

  /// uniqueId가 사용 가능한지 확인
  Future<bool> isUniqueIdAvailable(String uniqueId) async {
    final query =
        await _userRef.where('uniqueId', isEqualTo: uniqueId).limit(1).get();

    return query.docs.isEmpty;
  }

  Future<List<Map<String, dynamic>>> getUsersByUids(List<String> uids) async {
    if (uids.isEmpty) return [];

    final snapshot =
        await _userRef
            .where(FieldPath.documentId, whereIn: uids.take(10).toList())
            .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<String>> getFcmTokens(String uid) async {
    final userDoc = await _userRef.doc(uid).get();

    final tokens = userDoc.data()?['fcmTokens'] ?? [];

    if (tokens is List) {
      return tokens.cast<String>();
    } else {
      return [];
    }
  }

  Future<void> removeGroupId({
    required String uid,
    required String groupId,
  }) async {
    await _userRef.doc(uid).update({
      'groupIds': FieldValue.arrayRemove([groupId]),
    });
  }

  Future<void> addMessageToUser({
    required String uid,
    required Map<String, dynamic> messageData,
  }) async {
    final userMessageRef = _userRef.doc(uid).collection('messages');
    await userMessageRef.add({
      ...messageData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> streamMessageMapsForUser(String uid) {
    final userMessageRef = _userRef.doc(uid).collection('messages');

    return userMessageRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (querySnapshot) =>
              querySnapshot.docs.map((doc) {
                final data = doc.data();
                return {'id': doc.id, ...data};
              }).toList(),
        );
  }

  Future<void> markMessageAsRead({
    required String uid,
    required String messageId,
  }) async {
    final messageRef = _userRef.doc(uid).collection('messages').doc(messageId);
    await messageRef.update({'isRead': true});
  }

  Future<void> deleteMessageFromUser({
    required String uid,
    required String messageId,
  }) async {
    final messageRef = _userRef.doc(uid).collection('messages').doc(messageId);
    await messageRef.delete();
  }

  Future<bool> userHasGroup({required String uid, required String groupId}) {
    return _userRef
        .doc(uid)
        .get()
        .then((doc) => doc.data()?['groupIds']?.contains(groupId) ?? false);
  }

  Future<void> deleteAllMessagesFromUser(String uid) async {
    final messagesRef = _userRef.doc(uid).collection('messages');
    final messagesSnapshot = await messagesRef.get();

    for (final messageDoc in messagesSnapshot.docs) {
      await messageDoc.reference.delete();
    }
  }

  Future<void> removeFriendUid({
    required String currentUid,
    required String friendUid,
  }) async {
    await _userRef.doc(currentUid).update({
      'friendsUids': FieldValue.arrayRemove([friendUid]),
    });
  }
}
