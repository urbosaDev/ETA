import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';
import 'package:what_is_your_eta/presentation/models/friend_info_model.dart';

class GetSingleUserWithStatusUsecase {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  GetSingleUserWithStatusUsecase({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  }) : _authRepository = authRepository,
       _userRepository = userRepository;

  Future<FriendInfoModel> getSingleUserWithStatus(String targetUserUid) async {
    final myUid = _authRepository.getCurrentUser()!.uid;

    final results = await Future.wait([
      _userRepository.getUser(myUid),
      _userRepository.getUser(targetUserUid),
    ]);

    final myModel = results[0];
    final targetUser = results[1];

    if (targetUser == null) {
      return FriendInfoModel(
        userModel: UserModel.unknownWithUid(targetUserUid),
        status: UserStatus.deleted,
      );
    }

    if (myModel?.blockFriendsUids.contains(targetUserUid) == true) {
      return FriendInfoModel(
        userModel: UserModel.blocked(targetUserUid),
        status: UserStatus.blocked,
      );
    }

    return FriendInfoModel(userModel: targetUser, status: UserStatus.active);
  }
}
