import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:regroup/models/group.dart';

class GroupRepository {
  GroupRepository(this.docId)
      : document = FirebaseFirestore.instance.collection('groups').doc(docId);

  final String docId;
  final DocumentReference document;

  Stream<DocumentSnapshot<Object?>> getStream() {
    return document.snapshots();
  }

  Future<void> addGroup(Group group) {
    return document.set(group.toJson());
  }

  Future<bool> deleteGroup() async {
    // See: https://firebase.google.com/docs/firestore/solutions/delete-collections?hl=it

    bool success = true;
    String path = document.path;

    try {
      await FirebaseFunctions.instance
          .httpsCallable('recursiveDelete')
          .call({"path": path});
    } on FirebaseFunctionsException catch (error) {
      success = false;
      print("[deleteGroup] Delete failed");
      print(error.code);
      print(error.details);
      print(error.message);
    }

    return success;
  }

  void checkNeighbours(users) {
    FirebaseFunctions.instance
        .httpsCallable('checkNeighbours')
        .call({"docId": docId, "users": users});
  }
}
