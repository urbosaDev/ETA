import 'dart:async';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/message_model.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/data/repository/chat_repository.dart';

import 'package:what_is_your_eta/data/repository/user_%08repository.dart';

class PrivateChatRoomViewModel extends GetxController {
  final ChatRepository _chatRepository;
  final UserRepository _userRepository;

  final String chatRoomId;
  final String myUid;
  final String friendUid;

  PrivateChatRoomViewModel({
    required ChatRepository chatRepository,
    required UserRepository userRepository,

    required this.chatRoomId,
    required this.myUid,
    required this.friendUid,
  }) : _chatRepository = chatRepository,
       _userRepository = userRepository;

  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final Rxn<UserModel> friendModel = Rxn<UserModel>();
  final Rxn<UserModel> myModel = Rxn<UserModel>();

  StreamSubscription<UserModel>? _friendSub;
  StreamSubscription<UserModel>? _mySub;
  StreamSubscription<List<MessageWithSnapshot>>? _messageStreamSub;

  MessageWithSnapshot? _lastMessage;

  final RxBool isLoadingMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToMeAndFriend();

    loadInitial().then((_) {
      listenToNewMessages();
    });
  }

  Future<void> loadInitial() async {
    final messagesWithSnapshots = await _chatRepository.fetchInitialMessageDocs(
      chatRoomId,
    );
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
      final messagesWithSnapshots = await _chatRepository.fetchMoreMessageDocs(
        chatRoomId,
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
    _messageStreamSub = _chatRepository.streamLatestMessages(chatRoomId).listen(
      (messagesWithSnapshots) {
        if (messagesWithSnapshots.isEmpty) return;

        final msgs = messagesWithSnapshots.map((e) => e.model).toList();
        messages.assignAll(msgs);
        _lastMessage = messagesWithSnapshots.last;
        shouldScrollToBottom.value = true;
      },
    );
  }

  Future<void> sendMessage(String content) async {
    final myName = myModel.value?.name;
    if (content.trim().isEmpty || myName == null) return;

    final message = TextMessageModel(
      senderId: myUid,
      text: content.trim(),
      sentAt: DateTime.now(),
      readBy: [myUid],
    );

    await _chatRepository.sendMessage(chatRoomId, message);
  }

  void _listenToMeAndFriend() {
    _friendSub = _userRepository
        .streamUser(friendUid)
        .listen((user) => friendModel.value = user);
    _mySub = _userRepository
        .streamUser(myUid)
        .listen((user) => myModel.value = user);
  }

  @override
  void onClose() {
    _friendSub?.cancel();
    _mySub?.cancel();
    _messageStreamSub?.cancel();
    super.onClose();
  }
}
