import 'package:what_is_your_eta/data/model/location_model/user_location_model.dart';

import 'package:what_is_your_eta/data/model/penalty_model.dart';
import 'package:what_is_your_eta/data/model/promise_model.dart';
import 'package:what_is_your_eta/data/service/promise_service.dart';

abstract class PromiseRepository {
  Future<String> createPromise(PromiseModel promise);
  Future<void> updatePromise(PromiseModel promise);
  Future<PromiseModel?> getPromise(String promiseId);
  Stream<PromiseModel> streamPromise(String promiseId);
  Future<void> deletePromise(String promiseId);
  Future<List<PromiseModel>> getPromisesByIds(List<String> ids);

  Future<bool> addPenaltySuggestion({
    required String promiseId,
    required String uid,
    required String description,
  });
  Future<bool> votePenalty({
    required String promiseId,
    required String voterUid,
    required String targetUid,
  });
  Future<Map<String, dynamic>?> getPenaltySuggestionByUid({
    required String promiseId,
    required String targetUid,
  });
  Future<Penalty?> calculateSelectedPenalty(String promiseId);
  Future<void> setSelectedPenalty({
    required String promiseId,
    required Penalty penalty,
  });
  Future<void> updateUserLocation({
    required String promiseId,
    required String uid,
    required UserLocationModel userLocation,
  });
  Future<void> addArriveUserIdIfNotExists({
    required String promiseId,
    required String currentUid,
  });
  // Future<void> updatePenaltyVoters({
  //   required String promiseId,
  //   required List<String> voterUids,
  // });
  // Future<void> updatePenaltySuggesters({
  //   required String promiseId,
  //   required List<String> suggesterUids,
  // });
}

class PromiseRepositoryImpl implements PromiseRepository {
  final PromiseService _service;

  PromiseRepositoryImpl(this._service);

  @override
  Future<String> createPromise(PromiseModel promise) async {
    return await _service.createPromise(promise.toJson());
  }

  @override
  Future<void> updatePromise(PromiseModel promise) async {
    await _service.updatePromise(promise.id, promise.toJson());
  }

  @override
  Future<PromiseModel?> getPromise(String promiseId) async {
    final json = await _service.getPromise(promiseId);
    return json == null ? null : PromiseModel.fromJson(json);
  }

  @override
  Stream<PromiseModel> streamPromise(String promiseId) {
    return _service.streamPromise(promiseId).map(PromiseModel.fromJson);
  }

  @override
  Future<void> deletePromise(String promiseId) async {
    await _service.deletePromise(promiseId);
  }

  Future<List<PromiseModel>> getPromisesByIds(List<String> ids) async {
    final futures = ids.map(getPromise); // 기존 단일 getPromise 사용
    final results = await Future.wait(futures);
    return results.whereType<PromiseModel>().toList(); // null 제거
  }

  @override
  Future<bool> addPenaltySuggestion({
    required String promiseId,
    required String uid,
    required String description,
  }) async {
    if (uid.trim().isEmpty || description.trim().isEmpty) return false;

    final suggestions = await _service.getPenaltySuggestions(promiseId);
    if (suggestions == null) return false;
    if (suggestions.containsKey(uid)) return false;

    final newPenalty = Penalty(description: description, userIds: []).toJson();
    await _service.setPenaltySuggestion(
      promiseId: promiseId,
      uid: uid,
      suggestionJson: newPenalty,
    );

    return true;
  }

  @override
  Future<bool> votePenalty({
    required String promiseId,
    required String voterUid,
    required String targetUid,
  }) async {
    // 대상 penalty 항목 가져오기
    final data = await _service.getPenaltySuggestionByUid(
      promiseId: promiseId,
      targetUid: targetUid,
    );
    if (data == null) return false;

    // 현재 투표자 리스트 가져오기
    final currentVotes = List<String>.from(data['userIds']);

    // 이미 투표했는지 확인
    if (currentVotes.contains(voterUid)) return false;

    // 새 투표자 추가
    currentVotes.add(voterUid);

    // Firestore에 업데이트
    await _service.updateVoteUids(
      promiseId: promiseId,
      targetUid: targetUid,
      voteUids: currentVotes,
    );

    return true;
  }

  @override
  Future<Map<String, dynamic>?> getPenaltySuggestionByUid({
    required String promiseId,
    required String targetUid,
  }) async {
    return await _service.getPenaltySuggestionByUid(
      promiseId: promiseId,
      targetUid: targetUid,
    );
  }

  @override
  Future<Penalty?> calculateSelectedPenalty(String promiseId) async {
    final allSuggestions = await _service.getPenaltySuggestions(promiseId);
    if (allSuggestions == null || allSuggestions.isEmpty) return null;

    final penalties =
        allSuggestions.values.map((value) => Penalty.fromJson(value)).toList();

    // 최다 득표 수
    final maxVotes = penalties
        .map((p) => p.userIds.length)
        .fold(0, (a, b) => a > b ? a : b);

    // 동률 항목 추출
    final topPenalties =
        penalties.where((p) => p.userIds.length == maxVotes).toList();

    // 무작위 셔플 후 첫 번째 선택
    topPenalties.shuffle();
    return topPenalties.first;
  }

  @override
  Future<void> setSelectedPenalty({
    required String promiseId,
    required Penalty penalty,
  }) async {
    await _service.setSelectedPenalty(
      promiseId: promiseId,
      penaltyJson: penalty.toJson(),
    );
  }

  @override
  Future<void> updateUserLocation({
    required String promiseId,
    required String uid,
    required UserLocationModel userLocation,
  }) async {
    await _service.updateUserLocation(
      promiseId: promiseId,
      uid: uid,
      userLocationJson: userLocation.toJson(), // 여기서만 변환
    );
  }

  @override
  Future<void> addArriveUserIdIfNotExists({
    required String promiseId,
    required String currentUid,
  }) async {
    await _service.addArriveUserIdIfNotExists(
      promiseId: promiseId,
      currentUid: currentUid,
    );
  }
}
