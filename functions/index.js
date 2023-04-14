const functions = require("firebase-functions");
const firebaseTools = require("firebase-tools");

// For setting a fb.token
// firebase login:ci (this command will generate a token)
// firebase functions:config:set fb.token='TOKEN FROM THE PREVIOUS COMMAND'

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
