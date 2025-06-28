import 'dart:async';

import 'package:get/get.dart';

import 'package:what_is_your_eta/data/model/group_model.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/group_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';

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

  final selectedIndex = 0.obs; // 0: Chat, 1: Create

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

      //현재 선택된 그룹 ID
      final selectedGroupIndex = selectedIndex.value;
      if (selectedGroupIndex >= 2) {
        final selectedGroupId = oldGroupIds[selectedGroupIndex - 2];

        //해당 그룹이 삭제되었는지 체크
        if (!newGroupIds.contains(selectedGroupId)) {
          selectedIndex.value = 0; // 채팅 탭으로 리셋
        }
      }

      //groupList 갱신
      if (newGroupIds.isNotEmpty) {
        await _fetchGroups(newGroupIds);
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
