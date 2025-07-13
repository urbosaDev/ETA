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
    print('init홈뷰모델');

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
      final newGroupIds = userModel.groupIds; // 스트림으로 받은 최신 groupIds

      // 1. 그룹 목록을 먼저 최신 상태로 패치합니다.
      if (newGroupIds.isNotEmpty) {
        await _fetchGroups(newGroupIds);
      } else {
        _groupList.clear(); // 그룹이 없으면 목록 비움
      }

      // 2. 그룹 목록이 업데이트된 후, selectedIndex 유효성 검사 및 조정
      // 이 로직은 `_groupList` (업데이트된)를 기반으로 합니다.
      final selectedGroupIndex = selectedIndex.value;
      if (selectedGroupIndex >= 2) {
        // 현재 선택된 탭이 그룹 탭이라면
        // _groupList가 이미 업데이트되었으므로, 여기서 해당 그룹이 여전히 존재하는지 확인
        // selectedGroupId를 찾기 위해 oldGroupIds 대신 _groupList를 사용
        final String? currentSelectedGroupId =
            (selectedGroupIndex - 2) <
                    _groupList
                        .length // 인덱스 유효성 먼저 확인
                ? _groupList[selectedGroupIndex - 2].id
                : null;

        if (currentSelectedGroupId == null ||
            !newGroupIds.contains(currentSelectedGroupId)) {
          // 선택된 그룹 ID가 null이거나 (그룹이 사라졌거나)
          // newGroupIds에 현재 선택된 그룹 ID가 없으면 (내가 나갔거나 그룹이 삭제됨)
          selectedIndex.value = 0; // '메시지' 탭으로 초기화
          print(
            'DEBUG: Selected group no longer exists or is invalid. Resetting index to 0.',
          );
        }
      }
    });
  }

  Future<void> _fetchGroups(List<String> groupIds) async {
    final groups = await _groupRepository.getGroupsByIds(groupIds);
    _groupList.value = groups;
  }
}
