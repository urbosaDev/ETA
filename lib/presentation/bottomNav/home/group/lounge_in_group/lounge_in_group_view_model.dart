import 'dart:async';

import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/group_model.dart';
import 'package:what_is_your_eta/data/model/message_model.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';

import 'package:what_is_your_eta/data/repository/group_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';

class LoungeInGroupViewModel extends GetxController {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final GroupRepository _groupRepository;
  final String groupId;

  LoungeInGroupViewModel({
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required GroupRepository groupRepository,
    required this.groupId,
  }) : _authRepository = authRepository,
       _userRepository = userRepository,
       _groupRepository = groupRepository;

  final RxList<MessageModel> messages = <MessageModel>[].obs;
  RxMap<String, UserModel> memberMap = <String, UserModel>{}.obs;
  final RxBool isLoading = true.obs;
  final Rx<UserModel?> userModel = Rx<UserModel?>(null);
  final Rx<GroupModel?> groupModel = Rx<GroupModel?>(null);
  StreamSubscription<UserModel>? _userSub;
  StreamSubscription<GroupModel>? _groupSub;
  final RxList<UserModel> memberList = <UserModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    listenToMessages();
    _initialize();
  }

  @override
  void onClose() {
    _userSub?.cancel();
    _groupSub?.cancel();
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

    final fetchedGroup = await _groupRepository.getGroup(groupId);
    if (fetchedGroup == null) {
      isLoading.value = false;
      return;
    }
    groupModel.value = fetchedGroup;

    await _fetchMember(fetchedGroup.memberIds); // 먼저 memberMap 초기화
    listenToMessages(); //그 후 메시지 받기 시작
    _startGroupStream();

    isLoading.value = false;
  }

  // 본인 Stream 통해 유저 정보 업데이트
  void _startUserStream(String uid) {
    _userSub = _userRepository.streamUser(uid).listen((user) async {
      userModel.value = user;
    });
  }

  void _startGroupStream() {
    _groupSub = _groupRepository.streamGroup(groupId).listen((group) {
      groupModel.value = group;
      _fetchMember(group.memberIds);
    });
  }

  Future<void> _fetchMember(List<String> memberIds) async {
    final users = await _userRepository.getUsersByUids(memberIds);
    memberList.value = users;

    memberMap.value = {for (var u in users) u.uid: u};
  }
  // groupId 로 그룹모델을 불러오고 ,그룹모델 stream,
  //

  void listenToMessages() {
    _groupRepository.streamGroupMessages(groupId).listen((msgs) {
      messages.value = msgs;
    });
  }

  Future<void> sendMessage(String content) async {
    final msg = MessageModel(
      senderId: userModel.value!.uid,
      text: content,
      sentAt: DateTime.now(),
      readBy: [userModel.value!.uid],
    );
    await _groupRepository.sendGroupMessage(groupId, msg);
  }
}
