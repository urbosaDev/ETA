import 'package:what_is_your_eta/data/model/group_model.dart';
import 'package:what_is_your_eta/data/service/group_service.dart';

abstract class GroupRepository {
  Future<String> createGroup(GroupModel group);
  Future<void> updateGroup(GroupModel group);
  Future<GroupModel?> getGroup(String groupId);
  Stream<GroupModel> streamGroup(String groupId);
  Future<void> deleteGroup(String groupId);

  Future<List<GroupModel>> getGroupsByIds(List<String> groupIds);
  Stream<List<GroupModel>> streamGroupsByIds(List<String> groupIds);
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
    return _service.streamGroup(groupId).map(GroupModel.fromJson);
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    await _service.deleteGroup(groupId);
  }

  @override
  Future<List<GroupModel>> getGroupsByIds(List<String> groupIds) async {
    final jsonList = await _service.getGroupsByIds(groupIds);
    return jsonList.map(GroupModel.fromJson).toList();
  }

  @override
  Stream<List<GroupModel>> streamGroupsByIds(List<String> groupIds) {
    return _service
        .streamGroupsByIds(groupIds)
        .map((list) => list.map(GroupModel.fromJson).toList());
  }
}
