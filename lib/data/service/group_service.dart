import 'package:cloud_firestore/cloud_firestore.dart';

class GroupService {
  final _groupRef = FirebaseFirestore.instance.collection('groups');

  /// 그룹 생성
  Future<String> createGroup(Map<String, dynamic> group) async {
    final docRef = _groupRef.doc();
    await docRef.set({...group, 'id': docRef.id, 'chatRoomId': docRef.id});
    return docRef.id;
  }

  /// 그룹 일부 필드 업데이트
  Future<void> updateGroup(String groupId, Map<String, dynamic> json) async {
    await _groupRef.doc(groupId).update(json);
  }

  Future<void> sendGroupMessage(
    String groupId,
    Map<String, dynamic> json,
  ) async {
    final ref = _groupRef.doc(groupId).collection('messages');
    final doc = ref.doc();
    await doc.set({...json, 'id': doc.id});
  }

  Stream<List<Map<String, dynamic>>> streamGroupMessages(String groupId) {
    return _groupRef
        .doc(groupId)
        .collection('messages')
        .orderBy('sentAt')
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList());
  }

  // 멤버만 업데이트
  Future<void> updateGroupMembers(
    String groupId,
    List<String> memberIds,
  ) async {
    await updateGroup(groupId, {'memberIds': memberIds});
  }

  /// 그룹 조회
  Future<Map<String, dynamic>?> getGroup(String groupId) async {
    final doc = await _groupRef.doc(groupId).get();
    return doc.data();
  }

  /// 그룹 실시간 구독
  Stream<Map<String, dynamic>?> streamGroup(String groupId) {
    return _groupRef.doc(groupId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return doc.data();
    });
  }

  /// 그룹 삭제
  Future<void> deleteGroup(String groupId) async {
    final messages = await _groupRef.doc(groupId).collection('messages').get();
    for (final msg in messages.docs) {
      await msg.reference.delete();
    }
    await _groupRef.doc(groupId).delete();
  }

  /// 여러 그룹 조회 (예: 유저의 groupIds 기준)
  Future<List<Map<String, dynamic>>> getGroupsByIds(
    List<String> groupIds,
  ) async {
    if (groupIds.isEmpty) return [];

    final snapshot =
        await _groupRef
            .where(FieldPath.documentId, whereIn: groupIds.take(10).toList())
            .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // 메인 화면에서 보여줄 stream 그룹들 // firestore는 최대10개
  // 고로 유저는 10개 그룹만 속하도록 제한해야함
  Stream<List<Map<String, dynamic>>> streamGroupsByIds(List<String> groupIds) {
    if (groupIds.isEmpty) {
      return Stream.value([]);
    }

    return _groupRef
        .where(FieldPath.documentId, whereIn: groupIds.take(10).toList())
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> addPromiseIdToGroup({
    required String groupId,
    required String promiseId,
  }) async {
    await _groupRef.doc(groupId).update({
      'promiseIds': FieldValue.arrayUnion([promiseId]), // 중복 방지됨
    });
  }

  Future<void> removeUserFromGroup({
    required String groupId,
    required String userId,
  }) async {
    await _groupRef.doc(groupId).update({
      'memberIds': FieldValue.arrayRemove([userId]),
    });
  }
}
