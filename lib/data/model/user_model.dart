import 'package:what_is_your_eta/data/model/location_model/user_location_model.dart';

class UserModel {
  final String uid;
  final String uniqueId;
  final String name;
  final String photoUrl;
  final List<String> friendsUids;
  final List<String> groupIds;
  final List<String> privateChatIds;
  final UserLocationModel? location;

  const UserModel({
    required this.uid,
    required this.uniqueId,
    required this.name,
    required this.photoUrl,
    this.friendsUids = const [],
    this.groupIds = const [],
    this.privateChatIds = const [],
    this.location,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      uniqueId: json['uniqueId'],
      name: json['name'],
      photoUrl: json['photoUrl'],
      friendsUids: List<String>.from(json['friendsUids'] ?? []),
      groupIds: List<String>.from(json['groupIds'] ?? []),
      privateChatIds: List<String>.from(json['privateChatIds'] ?? []),
      location:
          json['location'] != null
              ? UserLocationModel.fromJson(json['location'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'uniqueId': uniqueId,
      'name': name,
      'photoUrl': photoUrl,
      'friendsUids': friendsUids,
      'groupIds': groupIds,
      'privateChatIds': privateChatIds,
      if (location != null) 'location': location!.toJson(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? uniqueId,
    String? name,
    String? photoUrl,
    List<String>? friendsUids,
    List<String>? groupIds,
    List<String>? privateChatIds,
    UserLocationModel? location,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      uniqueId: uniqueId ?? this.uniqueId,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      friendsUids: friendsUids ?? this.friendsUids,
      groupIds: groupIds ?? this.groupIds,
      privateChatIds: privateChatIds ?? this.privateChatIds,
      location: location ?? this.location,
    );
  }
}
