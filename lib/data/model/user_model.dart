import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid; // FireAuth Uid 로 구별
  final String uniqueId; // 유저가 직접 정한 Id
  final String name;
  final String photoUrl;
  final List<String> friendsUids; //친구리스트 uniqueId로 검색 후 uid로 저장
  final List<String> groupIds; // 속한 그룹 uid 목록
  final List<String> privateChatIds; //개인채팅 또한 uid로 저장
  final GeoPoint? lastKnownLocation;

  const UserModel({
    required this.uid,
    required this.uniqueId,
    required this.name,
    required this.photoUrl,
    this.friendsUids = const [],
    this.groupIds = const [],
    this.privateChatIds = const [],
    this.lastKnownLocation,
  });
  // firebase 에서 올때
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      uniqueId: json['uniqueId'] as String,
      name: json['name'] as String,
      photoUrl: json['photoUrl'] as String,
      friendsUids: List<String>.from(json['friendsUids'] ?? []),
      groupIds: List<String>.from(json['groupIds'] ?? []),
      privateChatIds: List<String>.from(json['privateChatIds'] ?? []),
      lastKnownLocation: json['lastKnownLocation'],
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
      'lastKnownLocation': lastKnownLocation,
    };
  }
  // copyWith은 불변성을 지킨 업데이트를 위해
  // ex) user.name = '김단' ㄴㄴ
  // user = user.copyWith(name: '김단') // 이렇게 사용
  // 이렇게 바뀐걸 FireStore에도 또 저장해야함
  //  // 변경된 모델 생성
  // final updatedUser = user.copyWith(
  //   friendUids: [...user.friendUids, 'uid789'],
  // );

  // // Firestore에 업데이트
  // FirebaseFirestore.instance
  //   .collection('users')
  //   .doc(updatedUser.uid)
  //   .update({
  //     'friendUids': updatedUser.friendUids,
  //   });

  UserModel copyWith({
    String? uid,
    String? uniqueId,
    String? name,
    String? photoUrl,
    List<String>? friendsUids,
    List<String>? groupIds,
    List<String>? privateChatIds,
    GeoPoint? lastKnownLocation,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      uniqueId: uniqueId ?? this.uniqueId,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      friendsUids: friendsUids ?? this.friendsUids,
      groupIds: groupIds ?? this.groupIds,
      privateChatIds: privateChatIds ?? this.privateChatIds,
      lastKnownLocation: lastKnownLocation ?? this.lastKnownLocation,
    );
  }
}
