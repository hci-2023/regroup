/* eslint-disbale */
const functions = require("firebase-functions");
const firebaseTools = require("firebase-tools");
const admin = require("firebase-admin");
const app = admin.initializeApp();


exports.recursiveDelete = functions
  .runWith({
    timeoutSeconds: 30,
    memory: "512MB",
  })
  .https.onCall(async (data, context) => {
    const path = data.path;

    let users = await admin.firestore().doc(path).collection("users").get();

    if (!users.empty) {
      const bucket = app.storage().bucket();

      users.forEach(async (user) => {
        userData = user.data();
        console.log(userData);

        if ("userPhotoUrl" in userData) {
          const photoPath = `images/${userData["deviceId"]}.jpg`;
          const photoFile = bucket.file(photoPath);

          try {
            await photoFile.delete();
            console.log(`File deleted successfully in path: ${photoPath}`);
          } catch (error) {
            console.log(`File NOT deleted: ${photoPath}`);
            console.log(`error: ${error}`);
          }
        }
      });

    }

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
  //usato per test
  //exports.checkNeighbours = functions.firestore.document('groups/{docId}/data/{docId1}').onWrite(async (change,context) => {
  console.log("Inizio checkNeighbours");
  //rimuovere commento dopo test
  const docId = req.docId;
  var utenti = req.users;

  //console.log("docid =",docId);
  //usato per test
  //const docId = "6ef2";
  var datiDict = {};
  var utentiList = [];

  //var dati = await admin.firestore().collection("dati").get();
  //var utenti = await admin.firestore().collection("utenti").get();

  var dati = await admin.firestore().collection("groups").doc(docId).collection("data").get();
  //var utenti = await admin.firestore().collection("groups").doc(docId).collection("users").get();

  dati.docs.map(obj => { 
    datiDict[obj.data().nome] = obj.data().vicini;
   });

  var docs = await admin.firestore().collection("groups").doc(docId).collection("data").listDocuments();
  docs.forEach(async (docs) => { await docs.delete() });

  utentiDict = {}
  roleDict = {}

  for (let user in utenti) {
    utentiList.push(utenti[user].deviceId);
    utentiDict[utenti[user].deviceId] = utenti[user].username;
    roleDict[utenti[user].deviceId] = utenti[user].role;
  };

  //utenti.docs.map(obj => { utentiList.push(obj.data().deviceId) });


  //utenti.docs.map(obj => { utentiDict[obj.data().deviceId] = obj.data().username });

  //roleDict = {}
  //utenti.docs.map(obj => { roleDict[obj.data().deviceId] = obj.data().role });

  //console.log(dict);
  //console.log(utenti);

  vicini = new Set();

  //inserisce i vicini in un unico insieme
  //x = chiave dizionario
  for (let x in datiDict) {
    //y = elemento lista in dict[x]
    for (let y of datiDict[x]) {
      vicini.add(y);
    }
  }
  //console.log(vicini);
  //trasforma il set in array perche js fa schifo e non ha l'intersezione tra set
  viciniList = Array.from(vicini);

  //utenti non rilevati
  var diff = utentiList.filter(function (x) {
    return viciniList.indexOf(x) < 0;
  });

  console.log("roleDict", roleDict);
  console.log("viciniList ", viciniList);
  console.log("utentiList ", utentiList);
  console.log("diff ", diff);
  console.log("utentidict ", utentiDict);
  //console.log(vicini);
  diffNomi = [];
  for (i in diff) {
    //console.log("diff[i] "+diff[i]);
    //console.log("i "+i);
    if (roleDict[diff[i]] == "participant") {
      diffNomi.push(utentiDict[diff[i]]);

    }
  }
  console.log("diffnomi", diffNomi);

  //prende i token a cui inviare la notifica, tutti gli utenti di un gruppo
  var allTokens = await admin.firestore().collection('groups').doc(docId).collection("users").get();
  var tokens = [];

  //rimuovere commento dopo test
  allTokens.docs.map(obj => { tokens.push(obj.data().token) });

  //console.log("tokens"+tokens);
  //console.log("token len"+tokens.length);
  if (tokens.length > 0 && diffNomi.length > 0) {
    const message = {
      notification: {
        title: "Lost participant",
        //usare diff non vicinilist
        body: diffNomi.join(', ') + " walked away",
      },
      tokens: tokens,
    };
    admin.messaging().sendMulticast(message);
  }
  //resetta lost
  for (let x in utentiList) {
    if (!diff.includes(utentiList[x])) {
      await admin.firestore().collection("groups").doc(docId).collection("users").doc(utentiList[x]).update({ lost: false });
    }
  }

  //setta lost
  for (let x in diff) {
    console.log("x in diff = " + diff[x]);
    console.log("role x in diff = " + roleDict[diff[x]]);
    if (diff.length > 0 && roleDict[diff[x]] == "participant") {
      await admin.firestore().collection("groups").doc(docId).collection("users").doc(diff[x]).update({ lost: true });
    }
  }

  console.log("Fine checkNeighbours");


});

