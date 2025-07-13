import 'dart:async';

import 'package:get/get.dart';

import 'package:what_is_your_eta/data/model/group_model.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/group_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';
import 'package:what_is_your_eta/presentation/bottomNav/bottom_nav_view_model.dart';

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

  final selectedIndex = 0.obs;

  StreamSubscription<UserModel>? _userSub;
  final RxnString groupIdToOpen = RxnString();
  @override
  void onInit() {
    super.onInit();
    _initUser();
    final bottomNavController = Get.find<BottomNavViewModel>();
    ever<String?>(bottomNavController.pendingGroupId, (groupId) {
      if (groupId == null) return;

      final index = _groupList.indexWhere((g) => g.id == groupId);
      if (index != -1) {
        selectedIndex.value = index + 2;
      }
      bottomNavController.pendingGroupId.value = null;
    });
  }

  void changeSideTabIndex(int index) {
    selectedIndex.value = index;
  }

  @override
  void onClose() {
    _userSub?.cancel();
    super.onClose();
    print('HomeViewModel closed');
  }

  void _initUser() {
    final user = _authRepository.getCurrentUser();
    if (user != null) {
      _startUserStream(user.uid);
    }
  }

  void _startUserStream(String uid) {
    _userSub = _userRepository.streamUser(uid).listen((userModel) async {
      final oldGroupIds = _groupList.map((g) => g.id).toList();
      final newGroupIds = userModel.groupIds;

      final selectedGroupIndex = selectedIndex.value;
      if (selectedGroupIndex >= 2) {
        final selectedGroupId = oldGroupIds[selectedGroupIndex - 2];

        if (!newGroupIds.contains(selectedGroupId)) {
          selectedIndex.value = 0;
        }
      }
      await _fetchGroups(newGroupIds);
      // if (newGroupIds.isNotEmpty) {
      // } else {
      //   _groupList.clear();
      // }
    });
  }

  Future<void> _fetchGroups(List<String> groupIds) async {
    final groups = await _groupRepository.getGroupsByIds(groupIds);
    _groupList.value = groups;
  }
}
