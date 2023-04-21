const functions = require("firebase-functions");
const firebaseTools = require("firebase-tools");
const admin = require("firebase-admin");
admin.initializeApp();


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


exports.checkNeighbours = functions.https.onCall(async (req, res) => {
  const docId = req.docId;
  console.log(docId);
  const datiDict = {};
  const utentiList = [];

  // var dati = await admin.firestore().collection("dati").get();
  // var utenti = await admin.firestore().collection("utenti").get();

  const dati = await admin.firestore()
      .collection("groups")
      .doc(docId)
      .collection("data")
      .get();
  const utenti = await admin.firestore()
      .collection("groups")
      .doc(docId)
      .collection("users")
      .get();


  dati.docs.map((obj) => {
    datiDict[obj.data().nome] = obj.data().vicini;
  });
  utenti.docs.map((obj) => {
    utentiList.push(obj.data().deviceId);
  });

  const utentiDict = {};
  utenti.docs.map((obj) => {
    utentiDict[obj.data().deviceId] = obj.data().username;
  });

  const roleDict = {};
  utenti.docs.map((obj) => {
    roleDict[obj.data().deviceId] = obj.data().role;
  });


  // console.log(dict);
  // console.log(utenti);

  const vicini = new Set();

  // inserisce i vicini in un unico insieme
  // x = chiave dizionario
  for (const x in datiDict) {
    // y = elemento lista in dict[x]
    if (x in datiDict) {
      for (const y of datiDict[x]) {
        if (y in datiDict[x]) {
          vicini.add(y);
        }
      }
    }
  }


  const viciniList = Array.from(vicini);

  // utenti non rilevati
  const diff = utentiList.filter((x) => {
    return viciniList.indexOf(x) < 0;
  });

  console.log(viciniList);
  console.log(utentiList);
  console.log(diff);
  console.log(utentiDict);
  // console.log(vicini);
  const diffNomi = [];
  for (const i in diff) {
    if (i in diff) {
      console.log(diff[i]);
      console.log(i);
      if (roleDict[diff[i]] == "participant") {
        diffNomi.push(utentiDict[diff[i]]);
      }
    }
  }
  console.log(diffNomi);

  // prende i token a cui inviare la notifica, tutti gli utenti di un gruppo
  const allTokens = await admin.firestore()
      .collection("groups")
      .doc(docId)
      .collection("users")
      .get();
  const tokens = [];
  allTokens.docs.map((obj) => {
    tokens.push(obj.data().token);
  });

  // console.log(tokens);

  /* const message = {
        notification: {
          title: "Lost participant",
          body: "A participant in your group walked away",
        },
        tokens: tokens,
      };*/

  const message = {
    notification: {
      title: "Lost participant",
      // usare diff non vicinilist
      body: diffNomi.toString() + " walked away",
    },
    tokens: tokens,
  };
  // if(tokens.length > 0){//debgug usare quella sotto
  if (tokens.length > 0 && diffNomi.length > 0) {
    admin.messaging().sendMulticast(message);
  }

  // console.log("fine funzione");
});
