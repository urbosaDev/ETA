import 'package:what_is_your_eta/data/model/user_model.dart';

enum UserStatus { active, blocked, deleted }

class FriendInfoModel {
  final UserModel userModel;
  final UserStatus status;

  FriendInfoModel({required this.userModel, required this.status});
}
