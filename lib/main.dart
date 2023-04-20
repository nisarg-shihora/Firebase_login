import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_demo/pages/home_screen.dart';
import 'package:firebase_demo/pages/sign_in.dart';
import 'package:firebase_demo/pages/sign_up.dart';
import 'package:flutter/material.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/home': (context) => const MyHomePage(),
        '/signup': (context) => const SignUp(),
        '/signin': (context) => const SignIn(),
      },
      home: const SignIn(),
    );
  }
}

