import 'dart:async';

import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/group_model.dart';

import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/fcm_repository.dart';
import 'package:what_is_your_eta/data/repository/group_repository.dart';

import 'package:what_is_your_eta/data/repository/user_%08repository.dart';
import 'package:what_is_your_eta/presentation/core/filter_words.dart';
import 'package:what_is_your_eta/presentation/models/friend_info_model.dart';

class CreateGroupViewModel extends GetxController {
  final GroupRepository _groupRepository;
  final UserRepository _userRepository;
  final AuthRepository _authRepository;
  final FcmRepository _fcmRepository;
  CreateGroupViewModel({
    required GroupRepository groupRepository,
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required FcmRepository fcmRepository,
  }) : _groupRepository = groupRepository,
       _authRepository = authRepository,
       _userRepository = userRepository,
       _fcmRepository = fcmRepository;

  final Rx<UserModel?> userModel = Rx<UserModel?>(null);

  final RxList<FriendInfoModel> friendList = <FriendInfoModel>[].obs;

  StreamSubscription<UserModel>? _userSub;

  final RxList<FriendInfoModel> selectedFriends = <FriendInfoModel>[].obs;

  final RxBool isCreating = false.obs;
  void toggleFriend(FriendInfoModel friend) {
    if (selectedFriends.any((f) => f.userModel.uid == friend.userModel.uid)) {
      selectedFriends.removeWhere(
        (f) => f.userModel.uid == friend.userModel.uid,
      );
    } else {
      selectedFriends.add(friend);
    }
  }

  final RxString groupTitle = ''.obs;

  List<FriendInfoModel> get validFriends =>
      friendList
          .where(
            (f) =>
                f.userModel.uniqueId != 'unknown' && !f.isBlocked, // 차단한 유저는 제외
          )
          .toList();

  final RxBool containsBlockedWordInTitle = false.obs;

  bool get isReadyToCreate =>
      groupTitle.isNotEmpty &&
      selectedFriends.isNotEmpty &&
      !containsBlockedWordInTitle.value;

  void onTitleChanged(String value) {
    groupTitle.value = value.trim();
    containsBlockedWordInTitle.value = FilterWords.containsBlockedWord(
      groupTitle.value,
    );
  }

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

  void _initUser() async {
    final user = _authRepository.getCurrentUser();
    if (user != null) {
      _startUserStream(user.uid);
      getUsersByUids(userModel.value?.friendsUids ?? []);
    } else {}
  }

  void _startUserStream(String uid) {
    _userSub = _userRepository.streamUser(uid).listen((user) {
      userModel.value = user;
      getUsersByUids(user.friendsUids);
    });
  }

  Future<void> getUsersByUids(List<String> uids) async {
    final users = await _userRepository.getUsersByUids(uids);
    final blockedUids = userModel.value?.blockFriendsUids ?? [];

    friendList.value =
        users.map((user) {
          final isBlocked = blockedUids.contains(user.uid);
          return FriendInfoModel(userModel: user, isBlocked: isBlocked);
        }).toList();
  }

  final RxBool isGroupCreated = false.obs;
  final RxString systemMessage = ''.obs;
  final RxBool isLoading = false.obs;
  Future<void> createGroup() async {
    if (isCreating.value) {
      // 중복 호출 방지: 이미 진행 중이라면 즉시 리턴
      return;
    }

    // 로딩 시작 및 상태 초기화
    isLoading.value = true;
    isCreating.value = true;
    systemMessage.value = '';
    isGroupCreated.value = false;

    final currentUser = userModel.value?.uid;

    // 필수 조건 검사 및 메시지 설정 (isReadyToCreate에 포함된 조건들을 다시 확인)
    if (currentUser == null) {
      systemMessage.value = '사용자 인증 정보를 찾을 수 없습니다. 다시 로그인해주세요.';
      isLoading.value = false;
      isCreating.value = false;
      return;
    }
    if (!isReadyToCreate) {
      if (groupTitle.value.isEmpty) {
        systemMessage.value = '그룹 이름을 입력해주세요.';
      } else if (groupTitle.value.length < 2 || groupTitle.value.length > 10) {
        systemMessage.value = '그룹 이름은 2자 이상 10자 이하로 입력해주세요.';
      } else if (containsBlockedWordInTitle.value) {
        systemMessage.value = '그룹 이름에 부적절한 단어가 포함되어 있습니다.';
      } else if (selectedFriends.isEmpty) {
        systemMessage.value = '친구를 한 명 이상 초대해주세요.';
      } else {
        systemMessage.value = '그룹 생성에 필요한 정보가 불완전합니다.';
      }
      isLoading.value = false;
      isCreating.value = false;
      return;
    }

    final finalSelectedUid = [
      currentUser,
      ...selectedFriends.map((u) => u.userModel.uid),
    ];

    final group = GroupModel(
      id: '',
      createrId: currentUser,
      title: groupTitle.value,
      memberIds: finalSelectedUid,
      chatRoomId: '',
      currentPromiseId: null,
      endPromiseIds: [],
      createdAt: DateTime.now(),
    );

    try {
      final groupId = await _groupRepository.createGroup(group);
      if (groupId.isEmpty) {
        systemMessage.value = '그룹 생성에 실패했습니다. 유효하지 않은 그룹 ID입니다.';
        return;
      }

      for (final uid in finalSelectedUid) {
        await _userRepository.addGroupId(uid, groupId);
      }

      final otherUids = finalSelectedUid.where((uid) => uid != currentUser);
      final tokenUidPairs = <Map<String, String>>[];
      for (final uid in otherUids) {
        final tokens = await _userRepository.getFcmTokens(uid);
        for (final token in tokens) {
          tokenUidPairs.add({'token': token, 'uid': uid});
        }
      }

      if (tokenUidPairs.isNotEmpty) {
        await _fcmRepository.sendGroupNotification(
          targetTokens: tokenUidPairs,
          groupName: groupTitle.value,
          message: '그룹이 생성되었습니다',
          groupId: groupId,
        );
      }

      isGroupCreated.value = true; // 성공 시 상태 업데이트
      systemMessage.value = '그룹이 성공적으로 생성되었습니다.'; // 성공 메시지 설정
    } catch (e) {
      systemMessage.value =
          '그룹 생성 중 알 수 없는 오류가 발생했습니다: ${e.toString()}'; // 실패 시 메시지 설정
      isGroupCreated.value = false; // 실패 시 상태 설정
    } finally {
      isLoading.value = false; // 로딩 최종 해제
      isCreating.value = false; // 중복 호출 플래그 해제
    }
  }
}
