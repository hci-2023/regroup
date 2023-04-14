
const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const firestore = admin.firestore();

const MAX_RETRY_ATTEMPTS = 3;

exports.recursiveDelete = functions
    .runWith({
      timeoutSeconds: 30,
      memory: "128MB",
    })
    .https.onCall(async (req, res) => {
    // See: https://firebase.google.com/docs/firestore/solutions/delete-collections?hl=it#cloud_function
    // TODO: catch error
      const docId = req.docId;

      let response = true;

      const documentRef = firestore
          .collection("groups")
          .doc(docId);

      const bulkWriter = firestore.bulkWriter();
      bulkWriter
          .onWriteError((error) => {
            if (
              error.failedAttempts < MAX_RETRY_ATTEMPTS
            ) {
              return true;
            } else {
              console.log("[recursiveDelete] Failed write at document: ",
                  error.documentRef.path);
              response = false;
              return false;
            }
          });


      await firestore.recursiveDelete(documentRef, bulkWriter);

      if (response) {
        return {
          "status": 200,
        };
      } else {
        return {
          "status": 500,
        };
      }
    },
    );
