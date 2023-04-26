import 'dart:io';

import 'package:flutter/material.dart';

class User with ChangeNotifier {
  String username = "";
  String deviceId = "";
  String? userPhotoLink;
  File? userPhoto;

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

  File? get getUserPhoto => userPhoto;

  void setUserPhoto(File? photo) {
    userPhoto = photo;
    notifyListeners();
  }
}
