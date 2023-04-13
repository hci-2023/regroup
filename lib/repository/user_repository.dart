import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:regroup/models/user.dart';

class UserRepository {
  UserRepository(this.docId)
      : collection = FirebaseFirestore.instance
            .collection('groups')
            .doc(docId)
            .collection("users");

  final String docId;
  final CollectionReference collection;

  Stream<QuerySnapshot> getStream() {
    return collection.snapshots();
  }

  Stream<DocumentSnapshot<Object?>> getUserStream(String userId) {
    return collection.doc(userId).snapshots();
  }

  Future<void> addUser(GroupUser user) {
    return collection.doc(user.deviceId).set(user.toJson());
  }

  void updateUser(GroupUser user) async {
    await collection.doc(user.deviceId).update(user.toJson());
  }

  Future<void> deleteUser(String userId) async {
    await collection.doc(userId).delete();
  }
}
