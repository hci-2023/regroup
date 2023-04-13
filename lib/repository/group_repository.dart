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

  Future<void> deleteGroup() async {
    // See: https://firebase.google.com/docs/firestore/solutions/delete-collections?hl=it
    await FirebaseFunctions.instance
        .httpsCallable('recursiveDelete')
        .call({"docId": docId}).then((value) {
      print(value);
    }).catchError((err) {
      print('[deleteGroup] failed: $err');
    });
  }
}
