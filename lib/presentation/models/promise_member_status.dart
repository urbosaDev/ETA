import 'package:what_is_your_eta/data/model/location_model/user_location_model.dart';

import 'package:what_is_your_eta/presentation/models/friend_info_model.dart';

enum MemberUpdateStatus { updated, notUpdated }

class PromiseMemberStatus {
  final FriendInfoModel user;
  final UserLocationModel? location;
  final double? distance;
  final MemberUpdateStatus updateStatus;

  final String? address;

  PromiseMemberStatus({
    required this.user,
    required this.location,
    required this.distance,
    required this.updateStatus,
    this.address,
  });
}
