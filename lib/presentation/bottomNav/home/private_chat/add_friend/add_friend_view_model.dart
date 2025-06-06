import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';

import 'package:what_is_your_eta/data/repository/user_%08repository.dart';

class AddFriendViewModel extends GetxController {
  final UserRepository _userRepository;
  AddFriendViewModel({required UserRepository userRepository})
    : _userRepository = userRepository;

  final Rxn<UserModel> currentUser = Rxn<UserModel>();

  void init(UserModel user) {
    currentUser.value = user;
  }

  final RxBool isUserNotFound = false.obs;
  final RxBool isFriend = false.obs;
  final RxBool isMe = false.obs;

  final Rxn<UserModel> searchedUser = Rxn<UserModel>();
  final RxBool isInputValid = false.obs;
  final RxBool isLoading = false.obs;

  void onInputChanged(String input) {
    isInputValid.value = input.trim().isNotEmpty;
  }

  Future<void> searchAddFriend(String uniqueId) async {
    isUserNotFound.value = false;
    isFriend.value = false;
    isMe.value = false;
    searchedUser.value = null;

    final trimmed = uniqueId.trim();
    final my = currentUser.value;
    if (my == null) return;

    if (trimmed == my.uniqueId) {
      isMe.value = true;
      return;
    }

    isLoading.value = true;

    final friendUid = await _userRepository.getUidByUniqueId(trimmed);
    if (friendUid == null) {
      isUserNotFound.value = true;
      isLoading.value = false;
      return;
    }

    if (my.friendsUids.contains(friendUid)) {
      isFriend.value = true;
      isLoading.value = false;
      return;
    }

    final friend = await _userRepository.getUser(friendUid);
    if (friend == null) {
      isUserNotFound.value = true;
      isLoading.value = false;
      return;
    }

    searchedUser.value = friend;
    isLoading.value = false;
  }

  Future<void> addFriend() async {
    final my = currentUser.value;
    final friend = searchedUser.value;
    if (my == null || friend == null) return;

    await _userRepository.addFriendUid(my.uid, friend.uid);
  }
}
