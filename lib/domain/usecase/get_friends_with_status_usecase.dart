import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';
import 'package:what_is_your_eta/presentation/models/friend_info_model.dart';

class GetFriendsWithStatusUsecase {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  GetFriendsWithStatusUsecase({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  }) : _authRepository = authRepository,
       _userRepository = userRepository;

  Future<List<FriendInfoModel>> assignStatusToUsers({
    required List<String> uids,
  }) async {
    final currentUser = _authRepository.getCurrentUser();
    if (currentUser == null) {
      return [];
    }
    final myModel = await _userRepository.getUser(currentUser.uid);
    if (myModel == null) {
      return [];
    }
    final blockUids = myModel.blockFriendsUids;
    final userList = await _userRepository.getUsersByUids(uids);
    final result =
        uids.map((uid) {
          if (blockUids.contains(uid)) {
            return FriendInfoModel(
              userModel: UserModel.blocked(uid),
              status: UserStatus.blocked,
            );
          }
          final user = userList.firstWhereOrNull((user) => user.uid == uid);

          if (user == null) {
            return FriendInfoModel(
              userModel: UserModel.unknownWithUid(uid),
              status: UserStatus.deleted,
            );
          } else {
            return FriendInfoModel(userModel: user, status: UserStatus.active);
          }
        }).toList();
    return result;
  }
}
