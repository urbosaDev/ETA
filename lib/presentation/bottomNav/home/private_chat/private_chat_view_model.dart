import 'dart:async';

import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';

class PrivateChatViewModel extends GetxController {
  final UserRepository _userRepository;
  final AuthRepository _authRepository;
  PrivateChatViewModel({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  }) : _authRepository = authRepository,
       _userRepository = userRepository;

  final Rx<UserModel?> _userModel = Rx<UserModel?>(null);
  UserModel? get userModel => _userModel.value;

  final RxList<UserModel> _friendList = <UserModel>[].obs;
  List<UserModel> get friendList => _friendList;

  StreamSubscription<UserModel>? _userSub;

  final RxBool _isLoading = true.obs;
  bool get isLoading => _isLoading.value;
  @override
  void onInit() {
    super.onInit();
    _isLoading.value = true;
    Future.microtask(() => _initUser());
    if (_userModel != null) {
      _isLoading.value = false;
    }
  }

  void _initUser() async {
    final user = _authRepository.getCurrentUser();
    if (user != null) {
      _startUserStream(user.uid);
      getUsersByUids(_userModel.value?.friendsUids ?? []);
    } else {
      // 로그아웃 처리 또는 에러 처리 필요
    }
  }

  void _startUserStream(String uid) {
    _userSub = _userRepository.streamUser(uid).listen((userModel) {
      _userModel.value = userModel;
    });
  }

  @override
  void onClose() {
    _userSub?.cancel(); // 꼭 해줘야 메모리 누수 방지됨
    super.onClose();
  }

  // userModel 내에서 친구 uid 있음,
  // 그 리스트만큼 반복해서 친구 userModel List를 뿌려야함
  // 언제언제 반복하냐면 UserModel이 바뀔때마다 반복해야함
  Future<void> getUsersByUids(List<String> uids) async {
    _friendList.value = await _userRepository.getUsersByUids(uids);
  }

  //친구추가
  // 일단 친구 uniqueId로 검색해서 uid를 가져온다.
  // 그 uid가 userModel에 있는지 확인한다.(중복이 되면 안됌)
  // 그 uid를 userModel에 추가한다.
  //
  //그 이전 친구추가하기를 할때, 검색을 우선 해야됌
  Future<void> addFriend(String uniqueId) async {
    final friendUid = await _userRepository.getUidByUniqueId(uniqueId);
    if (friendUid == null) {
      // 친구가 존재하지 않음
      return;
    }
    // await _userRepository.updateUser(UserModel user);
  }
}
