import 'package:cloud_firestore/cloud_firestore.dart';

class UserDataRepository {
  UserDataRepository(this.docId)
      : collection = FirebaseFirestore.instance
            .collection('groups')
            .doc(docId)
            .collection("data");

  final String docId;
  final CollectionReference collection;

  Future<void> addUserData(String userId, Map<String, dynamic> userData) {
    return collection.doc(userId).set(userData);
  }

  Future<void> deleteUser(String userId) async {
    await collection.doc(userId).delete();
  }
}
