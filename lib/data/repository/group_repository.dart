import 'package:what_is_your_eta/data/model/group_model.dart';
import 'package:what_is_your_eta/data/model/message_model.dart';
import 'package:what_is_your_eta/data/service/group_service.dart';

abstract class GroupRepository {
  Future<String> createGroup(GroupModel group);
  Future<void> updateGroup(GroupModel group);
  Future<GroupModel?> getGroup(String groupId);
  Stream<GroupModel> streamGroup(String groupId);
  Future<void> deleteGroup(String groupId);

  Future<List<GroupModel>> getGroupsByIds(List<String> groupIds);
  Stream<List<GroupModel>> streamGroupsByIds(List<String> groupIds);
  Future<void> updateGroupMembers(String groupId, List<String> memberIds);
  Future<void> sendGroupMessage(String groupId, MessageModel message);
  Stream<List<MessageModel>> streamGroupMessages(String groupId);
  Future<void> addPromiseIdToGroup({
    required String groupId,
    required String promiseId,
  });
  Future<void> removeUserFromGroup({
    required String groupId,
    required String userId,
  });
  Future<void> endCurrentPromise({
    required String groupId,
    required String promiseId,
  });
  Future<void> clearCurrentPromiseId(String groupId);
}

class GroupRepositoryImpl implements GroupRepository {
  final GroupService _service;

  GroupRepositoryImpl(this._service);

  @override
  Future<String> createGroup(GroupModel group) async {
    return await _service.createGroup(group.toJson());
  }

  @override
  Future<void> updateGroup(GroupModel group) async {
    await _service.updateGroup(group.id, group.toJson());
  }

  @override
  Future<GroupModel?> getGroup(String groupId) async {
    final json = await _service.getGroup(groupId);
    return json == null ? null : GroupModel.fromJson(json);
  }

  @override
  Stream<GroupModel> streamGroup(String groupId) {
    return _service
        .streamGroup(groupId)
        .where((json) => json != null)
        .map((json) => GroupModel.fromJson(json!));
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    await _service.deleteGroup(groupId);
  }

  @override
  Future<List<GroupModel>> getGroupsByIds(List<String> groupIds) async {
    final jsonList = await _service.getGroupsByIds(groupIds);

    return jsonList
        .where((json) => json != null)
        .map((json) => GroupModel.fromJson(json!))
        .toList();
  }

  @override
  Stream<List<GroupModel>> streamGroupsByIds(List<String> groupIds) {
    return _service
        .streamGroupsByIds(groupIds)
        .map((list) => list.map(GroupModel.fromJson).toList());
  }

  @override
  Future<void> sendGroupMessage(String groupId, MessageModel message) {
    return _service.sendGroupMessage(groupId, message.toJson());
  }

  @override
  Stream<List<MessageModel>> streamGroupMessages(String groupId) {
    return _service
        .streamGroupMessages(groupId)
        .map((list) => list.map(MessageModel.fromJson).toList());
  }

  @override
  Future<void> updateGroupMembers(
    String groupId,
    List<String> memberIds,
  ) async {
    await _service.updateGroupMembers(groupId, memberIds);
  }

  @override
  Future<void> addPromiseIdToGroup({
    required String groupId,
    required String promiseId,
  }) async {
    await _service.addPromiseIdToGroup(groupId: groupId, promiseId: promiseId);
  }

  @override
  Future<void> removeUserFromGroup({
    required String groupId,
    required String userId,
  }) async {
    await _service.removeUserFromGroup(groupId: groupId, userId: userId);
  }

  @override
  Future<void> endCurrentPromise({
    required String groupId,
    required String promiseId,
  }) async {
    await _service.endCurrentPromise(groupId: groupId, promiseId: promiseId);
  }

  @override
  Future<void> clearCurrentPromiseId(String groupId) {
    return _service.clearCurrentPromiseId(groupId);
  }
}
