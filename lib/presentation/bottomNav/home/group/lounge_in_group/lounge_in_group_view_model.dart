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
  final RxnString currentPromiseId = RxnString();

  StreamSubscription<List<MessageWithSnapshot>>? _messageStreamSub;
  MessageWithSnapshot? _lastMessage;
  final RxBool isLoadingMore = false.obs;
  @override
  void onInit() {
    super.onInit();
    _initialize();
    loadInitial().then((_) {
      listenToNewMessages();
    });
  }

  @override
  void onClose() {
    _userSub?.cancel();
    _groupSub?.cancel();
    _messageStreamSub?.cancel();
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
    currentPromiseId.value = fetchedGroup.currentPromiseId;
    await _fetchMember(fetchedGroup.memberIds); // 먼저 memberMap 초기화

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
      currentPromiseId.value = group.currentPromiseId;
    });
  }

  Future<void> _fetchMember(List<String> memberIds) async {
    final users = await _userRepository.getUsersByUids(memberIds);
    memberList.value = users;

    memberMap.value = {for (var u in users) u.uid: u};
  }
  // groupId 로 그룹모델을 불러오고 ,그룹모델 stream,
  //

  Future<void> sendMessage(String content) async {
    final msg = TextMessageModel(
      senderId: userModel.value!.uid,
      text: content,
      sentAt: DateTime.now(),
      readBy: [userModel.value!.uid],
    );
    await _groupRepository.sendGroupMessage(groupId, msg);
  }

  Future<void> loadInitial() async {
    final messagesWithSnapshots = await _groupRepository
        .fetchInitialMessageDocs(groupId);
    final msgs = messagesWithSnapshots.map((e) => e.model).toList();

    if (messagesWithSnapshots.isNotEmpty) {
      _lastMessage = messagesWithSnapshots.last;
    }

    messages.assignAll(msgs);
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || _lastMessage == null) return;

    isLoadingMore.value = true;
    try {
      final messagesWithSnapshots = await _groupRepository.fetchMoreMessageDocs(
        groupId,
        _lastMessage!,
      );
      if (messagesWithSnapshots.isEmpty) return;

      final msgs = messagesWithSnapshots.map((e) => e.model).toList();
      messages.addAll(msgs);

      _lastMessage = messagesWithSnapshots.last;
    } finally {
      isLoadingMore.value = false;
    }
  }

  final RxBool shouldScrollToBottom = false.obs;
  void listenToNewMessages() {
    _messageStreamSub = _groupRepository.streamLatestMessages(groupId).listen((
      messagesWithSnapshots,
    ) {
      if (messagesWithSnapshots.isEmpty) return;

      final msgs = messagesWithSnapshots.map((e) => e.model).toList();
      messages.assignAll(msgs);
      _lastMessage = messagesWithSnapshots.last;
      shouldScrollToBottom.value = true;
    });
  }
}
