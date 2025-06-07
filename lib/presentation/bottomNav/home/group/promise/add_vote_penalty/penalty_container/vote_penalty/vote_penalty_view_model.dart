import 'dart:async';

import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/message_model.dart';
import 'package:what_is_your_eta/data/model/promise_model.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/promise_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/add_vote_penalty/model/member_with_suggestion_vote_status.dart';

class VotePenaltyViewModel extends GetxController {
  final String promiseId;
  final PromiseRepository _promiseRepository;
  final UserRepository _userRepository;
  final AuthRepository _authRepository;

  VotePenaltyViewModel({
    required this.promiseId,
    required PromiseRepository promiseRepository,
    required UserRepository userRepository,
    required AuthRepository authRepository,
  }) : _promiseRepository = promiseRepository,
       _userRepository = userRepository,
       _authRepository = authRepository;
  final RxBool isLoading = true.obs;
  //fetch 및 stream 되는 promise
  final Rxn<PromiseModel> promise = Rxn<PromiseModel>();
  //fetch 및 stream 되는 user
  final Rx<UserModel?> userModel = Rx<UserModel?>(null);
  //fetch 되는 member list / promise 데이터를 가져올때 fetch
  final RxList<UserModel> memberList = <UserModel>[].obs;
  StreamSubscription<UserModel>? _userSub;
  StreamSubscription<PromiseModel>? _promiseSub;

  // 잠시 킵
  final RxBool allSuggested = false.obs;
  final RxBool allVoted = false.obs;
  final RxBool isSubmitting = false.obs;

  // 버튼에 처리하지말고 외부에 처리
  final RxnString errorMessage = RxnString();
  final RxnString successMessage = RxnString();
  final RxBool voteCompleted = false.obs;
  // 선택된 멤버 ()
  final Rxn<MemberWithSuggestionVoteStatus> selectedMember =
      Rxn<MemberWithSuggestionVoteStatus>();

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

    _userSub = _userRepository.streamUser(currentUser.uid).listen((user) {
      userModel.value = user;
    });
  }

  Future<void> _initPromiseAndMembers() async {
    final fetchedPromise = await _promiseRepository.getPromise(promiseId);
    if (fetchedPromise != null) {
      promise.value = fetchedPromise;
      await _fetchMembers(fetchedPromise.memberIds);
    }

    _promiseSub = _promiseRepository.streamPromise(promiseId).listen((p) async {
      promise.value = p;
      await _fetchMembers(p.memberIds);
    });
  }

  Future<void> _fetchMembers(List<String> memberIds) async {
    final users = await _userRepository.getUsersByUids(memberIds);
    memberList.value = users;
  }

  List<MemberWithSuggestionVoteStatus> get memberWithStatusList {
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

              return MemberWithSuggestionVoteStatus(
                user: user,
                hasSuggested: hasSuggested,
                description: description,
                isCurrentUser: user.uid == currentUid,
                hasVoted: hasVoted,
              );
            })
            .whereType<MemberWithSuggestionVoteStatus>()
            .toList();

    final votedUserIds = suggestions.values.expand((p) => p.userIds).toSet();
    allVoted.value = current.memberIds.every(
      (uid) => votedUserIds.contains(uid),
    );

    allSuggested.value = result.every((e) => e.hasSuggested);

    return result;
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

  Future<void> votePenaltyFlow() async {
    final success = await votePenalty();
    if (!success) return;

    final isLast = await isLastVote();
    if (isLast) {
      await finalizeSelectedPenalty();
      await notifyPenalty();
      voteCompleted.value = true;
    }
  }

  // Vote Penalty ----------------------
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

  // VotePenalty ----------------------
  Future<bool> isLastVote() async {
    final allSuggestions = promise.value?.penaltySuggestions?.values ?? [];
    final allMemberIds = promise.value?.memberIds ?? [];

    // 모든 투표된 userId 수집
    final allVoterIds = allSuggestions.expand((s) => s.userIds).toSet();

    // 모든 멤버가 투표했는지 체크
    return allMemberIds.every((uid) => allVoterIds.contains(uid));
  }

  // VotePenalty ----------------------
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

  // VotePenalty ----------------------
  bool get hasCurrentUserVoted {
    final currentUid = userModel.value?.uid;
    if (currentUid == null) return false;

    final suggestions = promise.value?.penaltySuggestions?.values ?? [];
    return suggestions.any((s) => s.userIds.contains(currentUid));
  }

  int get votedCount {
    final suggestions = promise.value?.penaltySuggestions?.values ?? [];
    final votedUserIds = suggestions.expand((s) => s.userIds).toSet();
    return votedUserIds.length;
  }

  // VotePenalty ----------------------
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

  // ----------------------
  void clearMessages() {
    successMessage.value = null;
    errorMessage.value = null;
  }

  @override
  void onClose() {
    _userSub?.cancel();
    _promiseSub?.cancel();
    super.onClose();
  }
}
