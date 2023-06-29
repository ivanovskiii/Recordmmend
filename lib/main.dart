import 'package:flutter/material.dart';
import 'package:recordmmend/screens/artistpage.dart';
import '/screens/signupscreen.dart';
import '/screens/homescreen.dart';
import '/screens/mainscreen.dart';
import '/screens/signinscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recordmmend',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      routes: {
        '/': (context) => HomeScreen(),
        '/signup': (context) => SignUpScreen(),
        '/login': (context) => SignInScreen(),
        '/main': (context) => MainScreen(user: null),
        // '/artist': (context) => ArtistPage(artistId: "null")
      },
    );
  }
}
