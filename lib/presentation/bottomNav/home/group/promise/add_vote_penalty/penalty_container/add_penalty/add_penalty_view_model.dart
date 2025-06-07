import 'dart:async';

import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/promise_model.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/promise_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/add_vote_penalty/model/member_with_suggestion_vote_status.dart';

class AddPenaltyViewModel extends GetxController {
  final String promiseId;
  final PromiseRepository _promiseRepository;
  final UserRepository _userRepository;
  final AuthRepository _authRepository;

  AddPenaltyViewModel({
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

  final RxBool allSuggested = false.obs;
  final RxBool allVoted = false.obs;
  final RxBool isSubmitting = false.obs;
  // 버튼에 처리하지말고 외부에 처리
  final RxnString errorMessage = RxnString();
  final RxnString successMessage = RxnString();
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

  // AddPenalty 진행도 리스트--------------------
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

  //  Add Penalty ----------------------
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

  bool get hasCurrentUserSuggested {
    final uid = userModel.value?.uid;
    if (uid == null) return false;
    return promise.value?.penaltySuggestions?.containsKey(uid) ?? false;
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
