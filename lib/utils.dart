import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

void showSnack(BuildContext context, String text,
        {int durationInMilliseconds = 800}) =>
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        duration: Duration(milliseconds: durationInMilliseconds),
      ),
    );

int groupIdToIdentifier(String groupId) {
  int accessIdentifier = 0;

  for (var element in groupId.codeUnits) {
    accessIdentifier = 2 * accessIdentifier + element;
  }

  return accessIdentifier;
}

String? validateUsername(String? value) {
  if (value == null || value.isEmpty || value.length < 3) {
    return 'Must be at least 3 characters';
  }
  return null;
}

Future<String?> uploadPhoto(String userId, File image) async {
  final storageRef = FirebaseStorage.instance.ref();
  String? photoUrl;

  final userPhotoRef = storageRef.child("images/$userId.jpg");

  try {
    var task = await userPhotoRef.putFile(image);
    photoUrl = await userPhotoRef.getDownloadURL();
  } catch (error) {
    print("[uploadPhoto] photo cannot be uploaded or obtain the download url");
    print("error: $error");
  }

  return photoUrl;
}

Future<void> deletePhoto(String userId) async {
  String photoPath = "images/$userId.jpg";
  final storageRef = FirebaseStorage.instance.ref();
  final userPhotoRef = storageRef.child(photoPath);

  try {
    await userPhotoRef.delete();
  } catch (error) {
    print(
        "[deletePhoto] the photo cannot at the following path cannot be deleted");
    print("path: $photoPath");
    print("error: $error");
  }
}
