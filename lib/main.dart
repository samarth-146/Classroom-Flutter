import 'package:classroom/signin.dart';
import 'package:flutter/material.dart';
import './register.dart';
import 'package:firebase_core/firebase_core.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: const FirebaseOptions(
  apiKey:"AIzaSyAefpzsXowFCGP4UwJ0zF8x1wHP3_SDomQ",
  appId: "1:955268353153:android:4ccbef227699eb50899180",
  messagingSenderId: "955268353153",
  projectId: "classroom-949b3",
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SignInPage(),
    );
  }
}