import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { owner, moderator, participant }

extension ParseToString on UserRole {
  String toShortString() {
    return toString().split('.').last;
  }
}

class GroupUser {
  String deviceId;
  String username;
  String role;
  bool lost;
  String? referenceId;
  String? userPhotoUrl;
  String? token;

  GroupUser(
      {required this.deviceId,
      required this.username,
      required this.role,
      required this.lost,
      this.referenceId,
      this.userPhotoUrl,
      this.token});

  factory GroupUser.fromJson(Map<String, dynamic> json) {
    return GroupUser(
        deviceId: json['deviceId'],
        username: json["username"],
        role: json["role"],
        lost: json["lost"],
        userPhotoUrl: json["userPhotoUrl"] ?? json["userPhotoUrl"],
        token: json["token"]);
  }

  Map<String, dynamic> toJson() => _toJson();

  @override
  String toString() =>
      'GroupUser<$deviceId;$username;$role${userPhotoUrl ?? ";$userPhotoUrl"};$token>';

  factory GroupUser.fromSnapshot(DocumentSnapshot snapshot) {
    final user = GroupUser.fromJson(snapshot.data() as Map<String, dynamic>);
    user.referenceId = snapshot.reference.id;
    return user;
  }

  Map<String, dynamic> _toJson() {
    Map<String, dynamic> userData = {
      'deviceId': deviceId,
      'username': username,
      'role': role,
      'lost': lost
    };
    if (userPhotoUrl != null) {
      userData['userPhotoUrl'] = userPhotoUrl;
    }
    userData['token'] = token;
    return userData;
  }

  bool get isLost => lost;

  void promote() {
    role = UserRole.moderator.toShortString();
  }

  void demote() {
    role = UserRole.participant.toShortString();
  }

  UserRole roleToEnum() {
    return UserRole.values.firstWhere((e) => e.toShortString() == role);
  }
}
