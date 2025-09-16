import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sos_blood_donation/pages/selectSignUp.dart';
import 'pages/home_page.dart';
import 'package:sos_blood_donation/pages/home_page.dart';
import 'package:sos_blood_donation/pages/sos_request_page.dart';
import 'pages/selectSignUp.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SOS Blood Donation',
      theme: ThemeData(primarySwatch: Colors.red),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData) {
            // User is logged in → go to HomePage
            return const HomePage();
          } else {
            // User not logged in → go to signup/login selection
            return const SelectSignUp();
          }
        },
      ),
    );
  }
}
