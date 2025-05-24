import 'dart:async';

import 'package:get/state_manager.dart';
import 'package:what_is_your_eta/data/model/group_model.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/group_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';

enum HomeTab { chat, create, group }

class HomeViewModel extends GetxController {
  final UserRepository _userRepository;
  final AuthRepository _authRepository;
  final GroupRepository _groupRepository;

  HomeViewModel({
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required GroupRepository groupRepository,
  }) : _authRepository = authRepository,
       _userRepository = userRepository,
       _groupRepository = groupRepository;

  final RxList<GroupModel> _groupList = <GroupModel>[].obs;
  List<GroupModel> get groupList => _groupList;

  final selectedIndex = 0.obs; // 0: Chat, 1: Create, 2~: Groups

  GroupModel? get selectedGroup {
    final index = selectedIndex.value - 2;
    if (index >= 0 && index < groupList.length) {
      return groupList[index];
    }
    return null;
  }

  StreamSubscription<UserModel>? _userSub;

  @override
  void onInit() {
    super.onInit();
    _initUser();
  }

  @override
  void onClose() {
    _userSub?.cancel();
    super.onClose();
  }

  void _initUser() {
    final user = _authRepository.getCurrentUser();
    if (user != null) {
      _startUserStream(user.uid);
    }
  }

  void _startUserStream(String uid) {
    _userSub = _userRepository.streamUser(uid).listen((userModel) {
      if (userModel.groupIds.isNotEmpty) {
        _fetchGroups(userModel.groupIds);
      } else {
        _groupList.clear();
      }
    });
  }

  Future<void> _fetchGroups(List<String> groupIds) async {
    final groups = await _groupRepository.getGroupsByIds(groupIds);
    _groupList.value = groups;
  }
}
