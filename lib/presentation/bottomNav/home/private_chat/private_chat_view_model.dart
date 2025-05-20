import 'dart:async';

import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/chat_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';

class PrivateChatViewModel extends GetxController {
  final UserRepository _userRepository;
  final AuthRepository _authRepository;
  final ChatRepository _chatRepository;
  PrivateChatViewModel({
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required ChatRepository chatRepository,
  }) : _authRepository = authRepository,
       _userRepository = userRepository,
       _chatRepository = chatRepository;

  final Rx<UserModel?> _userModel = Rx<UserModel?>(null);
  UserModel? get userModel => _userModel.value;

  final RxList<UserModel> _friendList = <UserModel>[].obs;
  List<UserModel> get friendList => _friendList;

  StreamSubscription<UserModel>? _userSub;

  final RxBool _isLoading = true.obs;
  bool get isLoading => _isLoading.value;
  @override
  void onInit() {
    super.onInit();
    _isLoading.value = true;
    Future.microtask(() => _initUser());
    ever(_userModel, (UserModel? user) {
      if (user != null) {
        getUsersByUids(user.friendsUids);
      }
    });
    _isLoading.value = false;
  }

  void _initUser() async {
    final user = _authRepository.getCurrentUser();
    if (user != null) {
      _startUserStream(user.uid);
      getUsersByUids(_userModel.value?.friendsUids ?? []);
    } else {
      // 로그아웃 처리 또는 에러 처리 필요
    }
  }

  void _startUserStream(String uid) {
    _userSub = _userRepository.streamUser(uid).listen((userModel) {
      _userModel.value = userModel;
    });
  }

  @override
  void onClose() {
    _userSub?.cancel(); // 꼭 해줘야 메모리 누수 방지됨
    super.onClose();
  }

  // userModel 내에서 친구 uid 있음,
  // 그 리스트만큼 반복해서 친구 userModel List를 뿌려야함
  // 언제언제 반복하냐면 UserModel이 바뀔때마다 반복해야함
  Future<void> getUsersByUids(List<String> uids) async {
    _friendList.value = await _userRepository.getUsersByUids(uids);
  }

  //친구추가
  // 일단 친구 uniqueId로 검색해서 uid를 가져온다.
  // 그 uid가 userModel에 있는지 확인한다.(중복이 되면 안됌)
  // 그 uid를 userModel에 추가한다.
  //
  //그 이전 친구추가하기를 할때, 검색을 우선 해야됌
  Future<void> addFriend(String uniqueId) async {
    final friendUid = await _userRepository.getUidByUniqueId(uniqueId);
    if (friendUid == null) {
      // 친구가 존재하지 않음
      return;
    }
    // await _userRepository.updateUser(UserModel user);
  }

  //중복 방지를 위한 , chat room id 생성 , 알파벳순 정렬
  String generateChatRoomId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  // 채팅방 생성은 채팅시작 버튼
  //
  Future<String?> createChatRoom(String friendUid) async {
    try {
      final myUid = _userModel.value!.uid;
      final chatRoomId = generateChatRoomId(myUid, friendUid);

      // ✅ 이미 존재하는 채팅방이 있는지 확인
      final exists = await _chatRepository.chatRoomExists(chatRoomId);
      if (exists) {
        return chatRoomId; // 👉 이미 존재하면 그냥 리턴
      }

      // ✅ 존재하지 않으면 생성
      final chatRoomData = {
        'participantIds': [myUid, friendUid],
        'lastMessage': '',
        'lastMessageAt': DateTime.now(),
      };

      await _chatRepository.createChatRoom(
        chatId: chatRoomId,
        data: chatRoomData,
      );

      // ✅ 양쪽 유저 모델 업데이트
      await _userRepository.addPrivateChatId(myUid, chatRoomId);
      await _userRepository.addPrivateChatId(friendUid, chatRoomId);

      return chatRoomId;
    } catch (e, stack) {
      print('🔥 채팅방 생성 오류: $e');
      print(stack);
      return null;
    }
  }
}
