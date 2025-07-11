// import 'package:what_is_your_eta/data/repository/auth_repository.dart';
// import 'package:what_is_your_eta/data/repository/chat_repository.dart';
// import 'package:what_is_your_eta/data/repository/user_%08repository.dart';

// class LeaveDeleteChatUsecase {
//   final ChatRepository _chatRepository;
//   final AuthRepository _authRepository;
//   final UserRepository _userRepository;

//   LeaveDeleteChatUsecase({
//     required ChatRepository chatRepository,
//     required AuthRepository authRepository,
//     required UserRepository userRepository,
//   }) : _chatRepository = chatRepository,
//        _authRepository = authRepository,
//        _userRepository = userRepository;

//   Future<void> leaveAndDelete(String chatRoomId) async {
//     final currentUser = _authRepository.getCurrentUser();
//     if (currentUser == null) return;

//     await _userRepository.removePrivateChatId(
//       uid: currentUser.uid,
//       chatRoomId: chatRoomId,
//     );
//     await _chatRepository.markUserAsLeftInChatRoom(
//       roomId: chatRoomId,
//       userId: currentUser.uid,
//     );
//     final updatedChatRoom = await _chatRepository.getChatRoom(chatRoomId);
//     if (updatedChatRoom != null) {
//       if (updatedChatRoom.participantIds.isEmpty) {
//         await _chatRepository.deleteChatRoom(chatRoomId);
//       } else {}
//     } else {}
//   }
// }
