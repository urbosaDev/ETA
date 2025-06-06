import 'dart:async';

import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/message_model.dart';
import 'package:what_is_your_eta/data/model/promise_model.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/promise_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';

class PenaltyContainerViewModel extends GetxController {
  final String promiseId;
  final PromiseRepository _promiseRepository;
  final UserRepository _userRepository;
  final AuthRepository _authRepository;

  PenaltyContainerViewModel({
    required this.promiseId,
    required PromiseRepository promiseRepository,
    required UserRepository userRepository,
    required AuthRepository authRepository,
  }) : _promiseRepository = promiseRepository,
       _userRepository = userRepository,
       _authRepository = authRepository;

  final RxInt currentPage = 0.obs;

  final Rxn<PromiseModel> promise = Rxn<PromiseModel>();
  final RxBool isLoading = true.obs;
  final Rx<UserModel?> userModel = Rx<UserModel?>(null);
  final RxList<UserModel> memberList = <UserModel>[].obs;
  StreamSubscription<UserModel>? _userSub;
  StreamSubscription<PromiseModel>? _promiseSub;
  final RxBool allSuggested = false.obs;
  final RxBool allVoted = false.obs;
  final RxBool isSubmitting = false.obs;

  final RxnString errorMessage = RxnString();
  final RxnString successMessage = RxnString();

  final Rxn<MemberWithSuggestionStatus> selectedMember =
      Rxn<MemberWithSuggestionStatus>();

  final Rxn<String> selectedDescription = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    isLoading.value = true;

    try {
      await _initUser();
      await _initPromiseAndMembers();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _initUser() async {
    final currentUser = _authRepository.getCurrentUser();
    if (currentUser == null) return;

    final initialUser = await _userRepository.getUser(currentUser.uid);
    if (initialUser != null) {
      userModel.value = initialUser;
    }

    _userSub?.cancel();
    _userSub = _userRepository.streamUser(currentUser.uid).listen((user) {
      userModel.value = user;
    });
  }

  int get votedCount {
    final suggestions = promise.value?.penaltySuggestions?.values ?? [];
    final votedUserIds = suggestions.expand((s) => s.userIds).toSet();
    return votedUserIds.length;
  }

  int get totalMemberCount {
    return promise.value?.memberIds.length ?? 0;
  }

  List<String> get uniqueDescriptions {
    final suggestions = promise.value?.penaltySuggestions?.values ?? [];
    final descriptions = suggestions.map((e) => e.description).toSet().toList();
    if (descriptions.isEmpty) return ["아직 정해지지 않음"];
    return descriptions;
  }

  Future<void> _initPromiseAndMembers() async {
    final fetchedPromise = await _promiseRepository.getPromise(promiseId);
    if (fetchedPromise != null) {
      promise.value = fetchedPromise;
      await _fetchMembers(fetchedPromise.memberIds);
    }
    _promiseSub?.cancel();
    _promiseSub = _promiseRepository.streamPromise(promiseId).listen((p) async {
      promise.value = p;
      await _fetchMembers(p.memberIds);
    });
  }

  Future<void> _fetchMembers(List<String> memberIds) async {
    final users = await _userRepository.getUsersByUids(memberIds);
    memberList.value = users;
  }

  List<MemberWithSuggestionStatus> get memberWithStatusList {
    final current = promise.value;
    if (current == null) return [];

    final suggestions = current.penaltySuggestions ?? {};
    final userMap = {for (var u in memberList) u.uid: u};
    final currentUid = userModel.value?.uid;

    final result =
        current.memberIds
            .map((uid) {
              final user = userMap[uid];
              if (user == null) return null;

              final penalty = suggestions[uid];
              final hasSuggested = penalty != null;
              final description = penalty?.description ?? '';

              final hasVoted = suggestions.values.any(
                (p) => p.userIds.contains(uid),
              );

              return MemberWithSuggestionStatus(
                user: user,
                hasSuggested: hasSuggested,
                description: description,
                isCurrentUser: user.uid == currentUid,
                hasVoted: hasVoted,
              );
            })
            .whereType<MemberWithSuggestionStatus>()
            .toList();

    final votedUserIds = suggestions.values.expand((p) => p.userIds).toSet();
    allVoted.value = current.memberIds.every(
      (uid) => votedUserIds.contains(uid),
    );

    allSuggested.value = result.every((e) => e.hasSuggested);

    return result;
  }

  Future<void> submitPenalty(String description) async {
    final currentUser = _authRepository.getCurrentUser();
    if (currentUser == null) {
      errorMessage.value = '로그인이 필요합니다.';
      return;
    }
    if (description.trim().isEmpty) {
      errorMessage.value = '입력창이 비어있습니다.';
      return;
    }

    final existing = promise.value?.penaltySuggestions?[currentUser.uid];
    if (existing != null) {
      errorMessage.value = '이미 벌칙을 제안하셨습니다.';
      return;
    }

    isSubmitting.value = true;
    try {
      final success = await _promiseRepository.addPenaltySuggestion(
        promiseId: promiseId,
        uid: currentUser.uid,
        description: description.trim(),
      );

      if (!success) {
        errorMessage.value = '벌칙 제안에 실패했습니다. 다시 시도해주세요.';
      } else {
        successMessage.value = '벌칙 제안이 완료되었습니다!';
      }
    } catch (e) {
      errorMessage.value = '오류가 발생했습니다.';
    } finally {
      isSubmitting.value = false;
    }
  }

  void clearMessages() {
    successMessage.value = null;
    errorMessage.value = null;
  }

  bool get hasCurrentUserSuggested {
    final uid = userModel.value?.uid;
    if (uid == null) return false;
    return promise.value?.penaltySuggestions?.containsKey(uid) ?? false;
  }

  Future<bool> votePenalty() async {
    final voterUid = userModel.value?.uid;
    final selected = selectedMember.value;
    if (voterUid == null || selected == null) {
      errorMessage.value = '선택된 항목이 없거나 로그인 정보가 없습니다.';
      return false;
    }

    isSubmitting.value = true;
    clearMessages();

    try {
      final success = await _promiseRepository.votePenalty(
        promiseId: promiseId,
        voterUid: voterUid,
        targetUid: selected.user.uid,
      );

      if (!success) {
        errorMessage.value = '이미 투표하셨거나 오류가 발생했습니다.';
        return false;
      }

      successMessage.value = '투표가 완료되었습니다.';
      return true;
    } catch (e) {
      errorMessage.value = '투표 중 문제가 발생했습니다.';
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> isLastVote() async {
    final allSuggestions = promise.value?.penaltySuggestions?.values ?? [];
    final allMemberIds = promise.value?.memberIds ?? [];

    // 모든 투표된 userId 수집
    final allVoterIds = allSuggestions.expand((s) => s.userIds).toSet();

    // 모든 멤버가 투표했는지 체크
    return allMemberIds.every((uid) => allVoterIds.contains(uid));
  }

  Future<void> finalizeSelectedPenalty() async {
    final selected = await _promiseRepository.calculateSelectedPenalty(
      promiseId,
    );
    print(selected);
    if (selected != null) {
      await _promiseRepository.setSelectedPenalty(
        promiseId: promiseId,
        penalty: selected,
      );
    }
  }

  bool get hasCurrentUserVoted {
    final currentUid = userModel.value?.uid;
    if (currentUid == null) return false;

    final suggestions = promise.value?.penaltySuggestions?.values ?? [];
    return suggestions.any((s) => s.userIds.contains(currentUid));
  }

  Future<bool> notifyPenalty() async {
    final content = '투표가 완료되어 벌칙이 생성되었습니다. 상단 벌칙 탭을 이용해 확인해보세요.';
    final msg = MessageModel(
      senderId: 'system',
      text: content,
      sentAt: DateTime.now(),
    );
    try {
      await _promiseRepository.sendPromiseMessage(promiseId, msg);
      return true; // 성공적으로 알림 전송
    } catch (e) {
      return false; // 알림 전송 실패
    }
  }

  @override
  void onClose() {
    _userSub?.cancel();
    _promiseSub?.cancel();
    super.onClose();
  }
}

class MemberWithSuggestionStatus {
  final UserModel user;
  final bool hasSuggested;
  final String? description;
  final bool isCurrentUser;
  final bool hasVoted;

  MemberWithSuggestionStatus({
    required this.user,
    required this.hasSuggested,
    this.description,
    required this.isCurrentUser,
    required this.hasVoted,
  });
}
