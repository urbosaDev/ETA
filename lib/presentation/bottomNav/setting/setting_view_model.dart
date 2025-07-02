import 'package:get/get.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/fcm_token_repository.dart';
import 'package:what_is_your_eta/data/repository/group_repository.dart';
import 'package:what_is_your_eta/data/repository/promise_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';

class SettingViewModel extends GetxController {
  final AuthRepository _authRepository;
  final FcmTokenRepository _fcmTokenRepository;
  final UserRepository _userRepository;
  final GroupRepository _groupRepository;
  final PromiseRepository _promiseRepository;

  SettingViewModel({
    required AuthRepository authRepository,
    required FcmTokenRepository fcmTokenRepository,
    required UserRepository userRepository,
    required GroupRepository groupRepository,
    required PromiseRepository promiseRepository,
  }) : _fcmTokenRepository = fcmTokenRepository,
       _authRepository = authRepository,
       _userRepository = userRepository,
       _groupRepository = groupRepository,
       _promiseRepository = promiseRepository;
  final RxBool isSignedOut = false.obs;

  Future<void> signOut() async {
    isLoading.value = true;
    try {
      await _fcmTokenRepository.deleteFcmToken();
      await _authRepository.signOut();
    } catch (e) {
      isLoading.value = false;
      return;
    }

    isSignedOut.value = true;
  }

  final RxBool isLoading = false.obs;
  final RxBool isDeleting = false.obs;
  Future<void> deleteAccount() async {
    isLoading.value = true;
    final user = _authRepository.getCurrentUser()?.uid;
    if (user == null) {
      isLoading.value = false;
      return;
    }
    final userModel = await _userRepository.getUser(user);
    if (userModel == null) {
      isLoading.value = false;
      return;
    }
    final groupIds = userModel.groupIds;
    for (final groupId in groupIds) {
      try {
        final group = await _groupRepository.getGroup(groupId);
        if (group == null) continue;
        final currentPromiseId = group.currentPromiseId;
        if (currentPromiseId == null) {
          continue;
        } else {
          // 현재 약속이 있는 경우, 해당 약속을 삭제
          await _promiseRepository.removeUserFromPromise(
            promiseId: currentPromiseId,
            userId: user,
          );
        }
        await _groupRepository.removeUserFromGroup(
          groupId: groupId,
          userId: user,
        );
      } catch (e) {}
    }

    try {
      await _fcmTokenRepository.deleteFcmToken();
      await _userRepository.deleteAllMessagesFromUser(user);
      await _userRepository.deleteUser(user);
      await _authRepository.deleteAccount();
      isDeleting.value = true;
    } catch (e) {
      isLoading.value = false;
      return;
    } finally {
      isLoading.value = false;
    }
  }
}
