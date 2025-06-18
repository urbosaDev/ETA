import 'dart:async';

import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';

class ProfileViewModel extends GetxController {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  ProfileViewModel({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  }) : _authRepository = authRepository,
       _userRepository = userRepository;

  final Rx<UserModel?> userModel = Rx<UserModel?>(null);
  final RxList<UserModel> friendList = <UserModel>[].obs;
  final RxBool isLoading = true.obs;
  StreamSubscription<UserModel>? _userSub;

  @override
  void onInit() {
    super.onInit();
    _initialize();
    // Initialize any necessary data or state here
  }

  @override
  void onClose() {
    // Clean up resources or subscriptions if needed
    _userSub?.cancel();
    super.onClose();
  }

  Future<void> _initialize() async {
    isLoading.value = true;
    final currentUser = _authRepository.getCurrentUser();
    if (currentUser != null) {
      final initialUser = await _userRepository.getUser(currentUser.uid);
      if (initialUser != null) {
        userModel.value = initialUser;
      }
      _startUserStream(currentUser.uid);
    }
    isLoading.value = false;
  }

  void _startUserStream(String uid) {
    _userSub = _userRepository.streamUser(uid).listen((user) async {
      userModel.value = user;
      await getUsersByUids(user.friendsUids);
    });
  }

  Future<void> getUsersByUids(List<String> uids) async {
    friendList.value = await _userRepository.getUsersByUids(uids);
  }
}
// userModel fetch, stream 
// 친구들도 fetch 
