import 'package:what_is_your_eta/data/model/message_model.dart';
import 'package:what_is_your_eta/data/model/promise_model.dart';
import 'package:what_is_your_eta/data/service/promise_service.dart';

abstract class PromiseRepository {
  Future<String> createPromise(PromiseModel promise);
  Future<void> updatePromise(PromiseModel promise);
  Future<PromiseModel?> getPromise(String promiseId);
  Stream<PromiseModel> streamPromise(String promiseId);
  Future<void> deletePromise(String promiseId);
  Future<List<PromiseModel>> getPromisesByIds(List<String> ids);
  Future<void> sendPromiseMessage(String promiseId, MessageModel message);
  Stream<List<MessageModel>> streamPromiseMessages(String promiseId);
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
  Future<void> sendPromiseMessage(String promiseId, MessageModel message) {
    return _service.sendPromiseMessage(promiseId, message.toJson());
  }

  @override
  Stream<List<MessageModel>> streamPromiseMessages(String promiseId) {
    return _service
        .streamPromiseMessages(promiseId)
        .map((list) => list.map(MessageModel.fromJson).toList());
  }
}
