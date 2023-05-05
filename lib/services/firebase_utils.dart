import 'package:cloud_firestore/cloud_firestore.dart';

Future<Map<String, dynamic>> isValidGroup(int accessIdentifier) async {
  Map<String, dynamic> response = {};

  final db = FirebaseFirestore.instance;

  var docRef = await db
      .collection("groups")
      .where("accessIdentifier", isEqualTo: accessIdentifier)
      .limit(1)
      .get();

  if (docRef.size != 0) {
    var doc = docRef.docs[0];
    response = doc.data();
  }

  return response;
}

Future<String?> memberStatus(String? deviceId) async {
  String? groupId;

  final db = FirebaseFirestore.instance;

  var docRef = await db
      .collectionGroup("users")
      .where("deviceId", isEqualTo: deviceId)
      .limit(1)
      .get();

  if (docRef.size != 0) {
    var doc = docRef.docs[0];
    var docReference = doc.reference;
    var collectionRef = docReference.parent.parent!.id;

    groupId = collectionRef;
  }

  return groupId;
}
