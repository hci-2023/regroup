import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:regroup/models/group.dart';

class GroupRepository {
  GroupRepository(this.docId) : document = FirebaseFirestore.instance.collection('groups').doc(docId);

  final String docId;
  final DocumentReference document;

  Stream<DocumentSnapshot<Object?>> getStream() {
    return document.snapshots();
  }

  Future<void> addGroup(Group group) {
    return document.set(group.toJson());
  }

  Future<HttpsCallableResult<dynamic>?> deleteGroup() async {
    // See: https://firebase.google.com/docs/firestore/solutions/delete-collections?hl=it
    HttpsCallableResult<dynamic>? response;

    try {
      response = await FirebaseFunctions.instance.httpsCallable('recursiveDelete').call({"docId": docId});
    } catch (e) {
      print('[recursiveDelete] Failed with error:\n$e');
    }

    return response;
  }
}
