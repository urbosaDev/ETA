import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final CollectionReference _userRef = FirebaseFirestore.instance.collection(
    'users',
  );

  /// 최초 가입 시 사용
  Future<void> setUserData(String uid, Map<String, dynamic> data) async {
    await _userRef.doc(uid).set(data);
  }

  /// 부분 업데이트
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    await _userRef.doc(uid).update(data);
  }

  /// 단건 조회
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _userRef.doc(uid).get();
    return doc.data() as Map<String, dynamic>?;
  }

  /// 유저 스트리밍
  Stream<Map<String, dynamic>> streamUserData(String uid) {
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

  /// 여러 명의 유저 불러오기 (예: 친구 목록)
  Future<List<Map<String, dynamic>>> getUsersByUids(List<String> uids) async {
    if (uids.isEmpty) return [];

    final snapshot =
        await _userRef
            .where(FieldPath.documentId, whereIn: uids.take(10).toList())
            .get();

    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }
}
