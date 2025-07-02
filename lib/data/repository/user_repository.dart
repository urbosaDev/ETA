import 'package:what_is_your_eta/data/model/notification_message_model.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/data/service/user_service.dart';

abstract class UserRepository {
  Future<void> createUser(UserModel user); // 최초 가입시,
  Future<void> updateUser(UserModel user); //항상 사용,채팅이생기든,그룹이생기든
  Future<UserModel?> getUser(String uid);
  // Future<UserModel?> getUserByUniqueId(String uniqueId); //유저 uniqueId로 검색 친구추가
  Stream<UserModel> streamUser(String uid);
  Future<void> deleteUser(String uid); // 회원탈퇴
  Future<void> addPrivateChatId(String uid, String chatRoomId);
  Future<bool> userExists(String uid); // 해당 UID 존재 여부, 회원가입시
  Future<String?> getUidByUniqueId(String uniqueId);
  Future<bool> isUniqueIdAvailable(String uniqueId);
  Future<List<UserModel>> getUsersByUids(List<String> uids);
  Future<void> addFriendUid(String currentUid, String friendUid);
  Future<void> addGroupId(String uid, String groupId); // 그룹생성시 유저 업데이트
  Future<List<String>> getFcmTokens(String uid);
  Future<void> removeGroupId({required String userId, required String groupId});
  Future<void> addMessageToUser({
    required String uid,
    required NotificationMessageModel message,
  });
  Stream<List<NotificationMessageModel>> streamNotificationMessages(String uid);
  Future<void> markMessageAsRead({
    required String uid,
    required String messageId,
  });
  Future<void> deleteMessageFromUser({
    required String uid,
    required String messageId,
  });
  Future<bool> userHasGroup({required String uid, required String groupId});
  Future<void> deleteAllMessagesFromUser(String uid);
  Future<void> removeFriendUid({
    required String currentUid,
    required String friendUid,
  });
  //유저차단
  Future<void> addBlockFriendUid({
    required String currentUid,
    required String blockFriendUid,
  });
  //유저 차단해제
  Future<void> removeBlockFriendUid({
    required String currentUid,
    required String blockFriendUid,
  });
}

class UserRepositoryImpl implements UserRepository {
  final UserService _userService;

  UserRepositoryImpl(this._userService);

  @override
  Future<void> createUser(UserModel user) async {
    await _userService.setUserData(user.uid, user.toJson());
  }

  @override
  Future<void> updateUser(UserModel user) async {
    await _userService.updateUserData(user.uid, user.toJson());
  }

  // 채팅방 생길때 유저정보 업데이트
  @override
  Future<void> addPrivateChatId(String uid, String chatRoomId) {
    return _userService.addPrivateChatId(uid, chatRoomId);
  }

  // 친구추가 로직
  @override
  Future<void> addFriendUid(String currentUid, String friendUid) async {
    await _userService.addFriendUid(currentUid, friendUid);
  }

  @override
  Future<UserModel> getUser(String uid) async {
    final json = await _userService.getUserData(uid);
    return json == null
        ? UserModel.unknownWithUid(uid)
        : UserModel.fromJson(json);
  }
  // @override
  // Future<UserModel?> getUserByUniqueId(String uniqueId) async {
  //   final json = await _userService.getUserDataByUniqueId(uniqueId);
  //   return json == null ? null : UserModel.fromJson(json);
  // }

  @override
  Stream<UserModel> streamUser(String uid) {
    return _userService.streamUserData(uid).map((json) {
      return json == null
          ? UserModel.unknownWithUid(uid)
          : UserModel.fromJson(json);
    });
  }

  @override
  Future<void> deleteUser(String uid) {
    return _userService.deleteUser(uid);
  }

  @override
  Future<bool> userExists(String uid) {
    return _userService.userExists(uid);
  }

  @override
  Future<String?> getUidByUniqueId(String uniqueId) {
    return _userService.getUidByUniqueId(uniqueId);
  }

  @override
  Future<bool> isUniqueIdAvailable(String uniqueId) {
    return _userService.isUniqueIdAvailable(uniqueId);
  }

  // @override
  // Future<List<UserModel>> getUsersByUids(List<String> uids) async {
  //   final jsonList = await _userService.getUsersByUids(uids);
  //   return jsonList.map((json) {
  //     if (json == null) return UserModel.unknown;
  //     return UserModel.fromJson(json);
  //   }).toList();
  // }
  @override
  Future<List<UserModel>> getUsersByUids(List<String> uids) async {
    final results = <UserModel>[];
    for (final uid in uids) {
      final json = await _userService.getUserData(uid);
      if (json == null) {
        results.add(UserModel.unknownWithUid(uid));
      } else {
        results.add(UserModel.fromJson(json));
      }
    }
    return results;
  }

  @override
  Future<void> addGroupId(String uid, String groupId) async {
    await _userService.addGroupId(uid, groupId);
  }

  @override
  Future<List<String>> getFcmTokens(String uid) async {
    final tokens = await _userService.getFcmTokens(uid);
    return tokens;
  }

  @override
  Future<void> removeGroupId({
    required String userId,
    required String groupId,
  }) {
    return _userService.removeGroupId(uid: userId, groupId: groupId);
  }

  @override
  Future<void> addMessageToUser({
    required String uid,
    required NotificationMessageModel message,
  }) {
    return _userService.addMessageToUser(
      uid: uid,
      messageData: message.toJson(),
    );
  }

  @override
  Stream<List<NotificationMessageModel>> streamNotificationMessages(
    String uid,
  ) {
    return _userService.streamMessageMapsForUser(uid).map((list) {
      return list
          .map((map) {
            final id = map['id'] as String;
            return NotificationMessageModel.fromJson(id, map);
          })
          .where((msg) => !msg.isRead) //isRead가 false인 메시지만 필터링
          .toList();
    });
  }

  @override
  Future<void> markMessageAsRead({
    required String uid,
    required String messageId,
  }) {
    return _userService.markMessageAsRead(uid: uid, messageId: messageId);
  }

  @override
  Future<void> deleteMessageFromUser({
    required String uid,
    required String messageId,
  }) {
    return _userService.deleteMessageFromUser(uid: uid, messageId: messageId);
  }

  @override
  Future<bool> userHasGroup({
    required String uid,
    required String groupId,
  }) async {
    return _userService.userHasGroup(uid: uid, groupId: groupId);
  }

  @override
  Future<void> deleteAllMessagesFromUser(String uid) async {
    return _userService.deleteAllMessagesFromUser(uid);
  }

  @override
  Future<void> removeFriendUid({
    required String currentUid,
    required String friendUid,
  }) async {
    return _userService.removeFriendUid(
      currentUid: currentUid,
      friendUid: friendUid,
    );
  }

  @override
  Future<void> addBlockFriendUid({
    required String currentUid,
    required String blockFriendUid,
  }) async {
    return _userService.addBlockFriendUid(
      currentUid: currentUid,
      blockFriendUid: blockFriendUid,
    );
  }

  @override
  Future<void> removeBlockFriendUid({
    required String currentUid,
    required String blockFriendUid,
  }) async {
    return _userService.removeBlockFriendUid(
      currentUid: currentUid,
      blockFriendUid: blockFriendUid,
    );
  }
}
