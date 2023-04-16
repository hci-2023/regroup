const functions = require("firebase-functions");
const firebaseTools = require("firebase-tools");

exports.recursiveDelete = functions
    .runWith({
      timeoutSeconds: 30,
      memory: "128MB",
    })
    .https.onCall(async (data, context) => {
      const path = data.path;

      await firebaseTools.firestore
          .delete(path, {
            project: process.env.GCLOUD_PROJECT,
            recursive: true,
            force: true,
            token: functions.config().fb.token,
          });

      return {
        path: path,
      };
    });
