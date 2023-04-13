import 'package:flutter/material.dart';

class User with ChangeNotifier {
  String username = "";
  String deviceId = "";
  String? userPhotoLink;

  String get getUsername => username;

  void setUsername(String name) {
    username = name;
    notifyListeners();
  }

  String get getDeviceId => deviceId;

  void setDeviceId(String uuid) {
    deviceId = uuid;
    notifyListeners();
  }

  String? get getUserPhotoLink => userPhotoLink;

  void setUserPhotoLink(String url) {
    userPhotoLink = url;
    notifyListeners();
  }
}
