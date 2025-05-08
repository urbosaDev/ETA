import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/data/service/user_service.dart';

abstract class UserRepository {
  Future<void> createUser(UserModel user);
  Future<void> updateUser(UserModel user);
  Future<UserModel?> getUser(String uid);
  Stream<UserModel> streamUser(String uid);
  Future<void> deleteUser(String uid);

  Future<bool> userExists(String uid);
  Future<String?> getUidByUniqueId(String uniqueId);
  Future<bool> isUniqueIdAvailable(String uniqueId);
  Future<List<UserModel>> getUsersByUids(List<String> uids);
}

class UserRepositoryImpl implements UserRepository {
  final UserService _userService;

  UserRepositoryImpl(this._userService);

  @override
  Future<void> createUser(UserModel user) async {
    await _userService.setUserData(user.uid, user.toJson());
  }

  @override
  Future<void> updateUser(UserModel user) async {
    await _userService.updateUserData(user.uid, user.toJson());
  }

  @override
  Future<UserModel?> getUser(String uid) async {
    final json = await _userService.getUserData(uid);
    return json == null ? null : UserModel.fromJson(json);
  }

  @override
  Stream<UserModel> streamUser(String uid) {
    return _userService.streamUserData(uid).map(UserModel.fromJson);
  }

  @override
  Future<void> deleteUser(String uid) {
    return _userService.deleteUser(uid);
  }

  @override
  Future<bool> userExists(String uid) {
    return _userService.userExists(uid);
  }

  @override
  Future<String?> getUidByUniqueId(String uniqueId) {
    return _userService.getUidByUniqueId(uniqueId);
  }

  @override
  Future<bool> isUniqueIdAvailable(String uniqueId) {
    return _userService.isUniqueIdAvailable(uniqueId);
  }

  @override
  Future<List<UserModel>> getUsersByUids(List<String> uids) async {
    final jsonList = await _userService.getUsersByUids(uids);
    return jsonList.map(UserModel.fromJson).toList();
  }
}
