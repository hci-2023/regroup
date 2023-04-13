import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:regroup/providers/user_provider.dart';
import 'package:regroup/views/allow_permissions.dart';
import 'package:regroup/views/home.dart';
import 'package:regroup/views/intro.dart';
import 'package:regroup/views/profile.dart';
import 'package:regroup/views/create_group.dart';
import 'package:regroup/views/join_group.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  //firestore.useFirestoreEmulator("localhost", 8080);

  FirebaseFunctions functions =
      FirebaseFunctions.instanceFor(region: "us-central1");
  //functions.useFunctionsEmulator("localhost", 5001);

  final storage = FirebaseStorage.instance;

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => User()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GroupIt',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: "/",
      routes: {
        "/": (context) => const HomePage(title: "GroupIt"),
        "/intro": (context) => const Intro(),
        "/userProfile": (context) => const Profile(),
        "/allowPermissions": (context) => const AllowPermissions(),
        "/createGroup": (context) => const CreateGroup(),
        "/joinGroup": (context) => const JoinGroup(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
