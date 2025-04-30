import 'package:cloud_firestore/cloud_firestore.dart';

class UserEntity {
  final String uid; // Firebase Auth UID
  final String uniqueId; // 유저가 직접 정한 중복 불가한 ID (ex. @dan123)
  final String name; // 유저 이름
  final String photoUrl; // 프로필 사진 URL
  final List<String> friendUids; // 친구 uid 리스트 // uniqueId를 통해 검색하고 uid를 받아옴
  final List<String> groupIds; // 속한 그룹 ID 목록
  final List<String> directChatIds;
  final GeoPoint? lastKnownLocation; // 최근 위치 정보 (nullable)

  const UserEntity({
    required this.uid,
    required this.uniqueId,
    required this.name,
    required this.photoUrl,
    this.friendUids = const [], //const 통해 리소스 최소화
    this.groupIds = const [],
    this.directChatIds = const [],
    this.lastKnownLocation,
  });
}
