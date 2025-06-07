import 'package:what_is_your_eta/data/model/user_model.dart';

class MemberWithSuggestionVoteStatus {
  final UserModel user;
  final bool hasSuggested;
  final String? description;
  final bool isCurrentUser;
  final bool hasVoted;

  MemberWithSuggestionVoteStatus({
    required this.user,
    required this.hasSuggested,
    this.description,
    required this.isCurrentUser,
    required this.hasVoted,
  });
}
