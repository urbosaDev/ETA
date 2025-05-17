import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';

import 'package:what_is_your_eta/data/repository/user_%08repository.dart';

class AddFriendViewModel extends GetxController {
  final UserRepository _userRepository;
  AddFriendViewModel({required UserRepository userRepository})
    : _userRepository = userRepository;

  late final UserModel currentUser;
  void init(UserModel user) {
    currentUser = user;
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
    // 초기화
    isUserNotFound.value = false;
    isFriend.value = false;
    isMe.value = false;
    searchedUser.value = null;

    final trimmed = uniqueId.trim();

    // 나 자신 체크
    if (trimmed == currentUser.uniqueId) {
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

    if (_isAlreadyFriend(friendUid)) {
      isFriend.value = true;
      isLoading.value = false;
      return;
    }

    // 친구 정보 가져오기
    final friend = await _userRepository.getUser(friendUid);
    if (friend == null) {
      isUserNotFound.value = true;
      isLoading.value = false;
      return;
    }

    searchedUser.value = friend;
    isLoading.value = false;
  }

  bool _isAlreadyFriend(String friendUid) {
    return currentUser.friendsUids.contains(friendUid);
  }

  Future<void> addFriend() async {
    final friend = searchedUser.value;
    if (friend == null) return;

    await _userRepository.addFriendUid(currentUser.uid, friend.uid);
  }
}
//보다 보충해야 하는 것, 
//1. 나 자신은 포함하면 안됌 , 
//2. 흠 일단 바로 친구 추가하면 안됌 . 해당 정보를 띄워야함 그리고 새로운 버튼이 생겨야함 