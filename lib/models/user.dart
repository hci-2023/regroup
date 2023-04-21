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
  String? referenceId;
  String? userPhotoUrl;
  String? token;

  GroupUser(
      {required this.deviceId,
      required this.username,
      required this.role,
      this.referenceId,
      this.userPhotoUrl,
      this.token});

  factory GroupUser.fromJson(Map<String, dynamic> json) {
    return GroupUser(
        deviceId: json['deviceId'],
        username: json["username"],
        role: json["role"],
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
      'username': username,
      'role': role,
      'deviceId': deviceId,
      'token': token
    };
    if (userPhotoUrl != null) {
      userData['userPhotoUrl'] = userPhotoUrl;
    }
    return userData;
  }

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
