import 'package:what_is_your_eta/data/model/user_model.dart';

class FriendInfoModel {
  final UserModel userModel;
  final bool isBlocked;

  FriendInfoModel({required this.userModel, required this.isBlocked});
}
