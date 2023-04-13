
const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const firestore = admin.firestore();

exports.recursiveDelete = functions.https.onCall(async (req, res) => {
  // See: https://firebase.google.com/docs/firestore/solutions/delete-collections?hl=it#cloud_function
  // TODO: catch error
  const docId = req.docId;

  const documentRef = firestore
      .collection("groups")
      .doc(docId);

  firestore.recursiveDelete(documentRef);
},
);
