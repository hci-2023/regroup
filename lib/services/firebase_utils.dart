import 'package:cloud_firestore/cloud_firestore.dart';

Future<String?> isValidGroup(int accessIdentifier) async {
  String? groupId;

  final db = FirebaseFirestore.instance;

  var docRef = await db
      .collection("groups")
      .where("accessIdentifier", isEqualTo: accessIdentifier)
      .limit(1)
      .get();

  if (docRef.size != 0) {
    var doc = docRef.docs[0];
    groupId = doc.reference.id;
  }

  return groupId;
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
