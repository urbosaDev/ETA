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
    return _promiseRef.doc(promiseId).snapshots().map((doc) => doc.data()!);
  }

  /// 삭제
  Future<void> deletePromise(String promiseId) async {
    await _promiseRef.doc(promiseId).delete();
  }

  Future<void> sendPromiseMessage(
    String promiseId,
    Map<String, dynamic> json,
  ) async {
    final ref = _promiseRef.doc(promiseId).collection('messages');
    final doc = ref.doc();
    await doc.set({...json, 'id': doc.id});
  }

  Stream<List<Map<String, dynamic>>> streamPromiseMessages(String promiseId) {
    return _promiseRef
        .doc(promiseId)
        .collection('messages')
        .orderBy('sentAt')
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList());
  }

  Future<void> setPenaltySuggestion({
    required String promiseId,
    required String uid,
    required Map<String, dynamic> suggestionJson,
  }) async {
    await _promiseRef.doc(promiseId).update({
      'penaltySuggestions.$uid': suggestionJson,
    });
  }

  // penaltySuggestions 전체 조회
  Future<Map<String, dynamic>?> getPenaltySuggestions(String promiseId) async {
    final doc = await _promiseRef.doc(promiseId).get();
    return doc.data()?['penaltySuggestions'] as Map<String, dynamic>?;
  }

  // 특정 항목의 voteUids 업데이트
  Future<void> setVoteUids({
    required String promiseId,
    required String targetUid,
    required List<String> voteUids,
  }) async {
    await _promiseRef.doc(promiseId).update({
      'penaltySuggestions.$targetUid.userIds': voteUids,
    });
  }

  Future<Map<String, dynamic>?> getPenaltySuggestionByUid({
    required String promiseId,
    required String targetUid,
  }) async {
    final doc = await _promiseRef.doc(promiseId).get();
    final suggestions =
        doc.data()?['penaltySuggestions'] as Map<String, dynamic>?;
    if (suggestions == null) return null;

    final data = suggestions[targetUid];
    if (data is! Map<String, dynamic>) return null;

    return data;
  }

  Future<void> updateVoteUids({
    required String promiseId,
    required String targetUid,
    required List<String> voteUids,
  }) async {
    await _promiseRef.doc(promiseId).update({
      'penaltySuggestions.$targetUid.userIds': voteUids,
    });
  }

  Future<void> setSelectedPenalty({
    required String promiseId,
    required Map<String, dynamic> penaltyJson,
  }) async {
    await _promiseRef.doc(promiseId).update({'selectedPenalty': penaltyJson});
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
  // Future<void> updatePenaltyVoters({
  //   required String promiseId,
  //   required List<String> voterUids,
  // }) async {
  //   await _promiseRef.doc(promiseId).update({'penaltyVoterUids': voterUids});
  // }

  // Future<void> updatePenaltySuggesters({
  //   required String promiseId,
  //   required List<String> suggesterUids,
  // }) async {
  //   await _promiseRef.doc(promiseId).update({
  //     'penaltySuggesterUids': suggesterUids,
  //   });
  // }
}
