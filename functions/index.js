/* eslint-disbale */
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
  console.log("docid =", docId);
  let datiDict = {};
  let utentiList = [];

  //let dati = await admin.firestore().collection("dati").get();
  //let utenti = await admin.firestore().collection("utenti").get();

  let dati = await admin.firestore().collection("groups").doc(docId).collection("data").get();
  let utenti = await admin.firestore().collection("groups").doc(docId).collection("users").get();


  //console.log(prova.docChanges().map(obj => { return { data: obj.doc.data(), change: obj.type}}));
  //prova.docs.map(obj => {console.log(obj.data())});
  dati.docs.map(obj => { datiDict[obj.data().nome] = obj.data().vicini });
  utenti.docs.map(obj => { utentiList.push(obj.data().deviceId) });

  utentiDict = {}
  utenti.docs.map(obj => { utentiDict[obj.data().deviceId] = obj.data().username });

  roleDict = {}
  utenti.docs.map(obj => { roleDict[obj.data().deviceId] = obj.data().role });



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
  let diff = utentiList.filter(function (x) {
    return viciniList.indexOf(x) < 0;
  });

  console.log("viciniList", viciniList);
  console.log("utentiList", utentiList);
  console.log("diff", diff);
  console.log("utentidict", utentiDict);
  //console.log(vicini);
  diffNomi = [];
  for (i in diff) {
    console.log(diff[i]);
    console.log(i);
    if (roleDict[diff[i]] == "participant") {
      diffNomi.push(utentiDict[diff[i]]);

    }
  }
  console.log("diffnomi", diffNomi);

  //prende i token a cui inviare la notifica, tutti gli utenti di un gruppo
  let allTokens = await admin.firestore().collection('groups').doc(docId).collection("users").get();
  let tokens = [];
  allTokens.docs.map(obj => { tokens.push(obj.data().token) });

  //console.log(tokens);

  /*const message = {
    notification: {
      title: "Lost participant",
      body: "A participant in your group walked away",
    },
    tokens: tokens,
  };*/

  const message = {
    notification: {
      title: "Lost participant",
      //usare diff non vicinilist
      body: diffNomi.toString() + " walked away",
    },
    tokens: tokens,
  };
  //if(tokens.length > 0){//debgug usare quella sotto
  if (tokens.length > 0 && diffNomi.length > 0) {
    admin.messaging().sendMulticast(message);
  }

  //console.log("fine funzione");


});