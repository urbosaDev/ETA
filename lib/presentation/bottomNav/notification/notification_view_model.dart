import 'dart:async';

import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/notification_message_model.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';

import 'package:what_is_your_eta/data/repository/group_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';

class NotificationViewModel extends GetxController {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  final GroupRepository _groupRepository;

  NotificationViewModel({
    required AuthRepository authRepository,
    required UserRepository userRepository,

    required GroupRepository groupRepository,
  }) : _authRepository = authRepository,
       _userRepository = userRepository,

       _groupRepository = groupRepository;

  final Rx<UserModel?> userModel = Rx<UserModel?>(null);
  final RxList<UserModel> friendList = <UserModel>[].obs;
  final RxBool isLoading = true.obs;
  StreamSubscription<UserModel>? _userSub;

  final RxList<NotificationMessageModel> unreadMessages =
      <NotificationMessageModel>[].obs;
  StreamSubscription<List<NotificationMessageModel>>? _messageSub;
  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  @override
  void onClose() {
    _userSub?.cancel();
    _messageSub?.cancel();
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
    });
    _messageSub = _userRepository.streamNotificationMessages(uid).listen((
      messages,
    ) {
      unreadMessages.assignAll(messages);
    });
  }

  Future<void> markMessageAsRead(String messageId) async {
    final uid = userModel.value?.uid;
    if (uid != null) {
      await _userRepository.markMessageAsRead(uid: uid, messageId: messageId);
    }
  }

  Future<void> deleteMessage(String messageId) async {
    final uid = userModel.value?.uid;
    if (uid != null) {
      await _userRepository.deleteMessageFromUser(
        uid: uid,
        messageId: messageId,
      );
    }
  }

  final RxnString errorMessage = RxnString(null);
  final RxBool canEnterGroup = false.obs;
  final RxBool isNavigating = false.obs;
  Future<void> checkGroupNavigation(String groupId) async {
    isNavigating.value = true;
    final uid = userModel.value?.uid;
    if (uid == null) {
      canEnterGroup.value = false;
      isNavigating.value = false;
      return;
    }

    final exists = await _groupRepository.existsGroup(groupId);
    if (!exists) {
      errorMessage.value = '존재하지 않는 그룹입니다.';
      canEnterGroup.value = false;
      isNavigating.value = false;
      return;
    }

    final has = await _userRepository.userHasGroup(uid: uid, groupId: groupId);
    if (!has) {
      errorMessage.value = '속해있지 않은 그룹입니다.';
      canEnterGroup.value = false;
      isNavigating.value = false;
      return;
    }
    await Future.delayed(const Duration(milliseconds: 500));
    errorMessage.value = null;
    canEnterGroup.value = true;
    isNavigating.value = false;
  }

  Future<void> deleteAllMessagesAsRead() async {
    final uid = userModel.value?.uid;
    if (uid == null) return;

    try {
      await _userRepository.deleteAllMessagesFromUser(uid);
      unreadMessages.clear();
    } catch (e) {}
  }

  String formatNotificationTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${time.year}년 ${time.month}월 ${time.day}일';
    }
  }
}
