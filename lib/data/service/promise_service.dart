import 'package:cloud_firestore/cloud_firestore.dart';

class PromiseService {
  final _promiseRef = FirebaseFirestore.instance.collection('promises');

  /// 약속 생성 (Firestore에서 ID 자동 생성)
  Future<String> createPromise(Map<String, dynamic> data) async {
    final docRef = _promiseRef.doc();
    await docRef.set({...data, 'id': docRef.id});
    return docRef.id;
  }

  /// 약속 필드 업데이트
  Future<void> updatePromise(
    String promiseId,
    Map<String, dynamic> data,
  ) async {
    await _promiseRef.doc(promiseId).update(data);
  }

  /// 단건 조회
  Future<Map<String, dynamic>?> getPromise(String promiseId) async {
    final doc = await _promiseRef.doc(promiseId).get();
    return doc.data();
  }

  /// 실시간 구독
  Stream<Map<String, dynamic>> streamPromise(String promiseId) {
    return _promiseRef.doc(promiseId).snapshots().map((doc) {
      return doc.data()!;
    });
  }

  /// 삭제
  Future<void> deletePromise(String promiseId) async {
    await _promiseRef.doc(promiseId).delete();
  }

  Future<void> updateUserLocation({
    required String promiseId,
    required String uid,
    required Map<String, dynamic> userLocationJson,
  }) async {
    await _promiseRef.doc(promiseId).update({
      'userLocations.$uid': userLocationJson,
    });
  }

  Future<void> updateArriveUserIds({
    required String promiseId,
    required List<String> arriveUserIds,
  }) async {
    await _promiseRef.doc(promiseId).update({'arriveUserIds': arriveUserIds});
  }

  Future<void> addArriveUserIdIfNotExists({
    required String promiseId,
    required String currentUid,
  }) async {
    await _promiseRef.doc(promiseId).update({
      'arriveUserIds': FieldValue.arrayUnion([currentUid]),
    });
  }

  Future<void> removeUserFromPromise({
    required String promiseId,
    required String userId,
  }) async {
    await _promiseRef.doc(promiseId).update({
      'memberIds': FieldValue.arrayRemove([userId]),
      'arriveUserIds': FieldValue.arrayRemove([userId]),
      'userLocations.$userId': FieldValue.delete(),
    });
  }
}
