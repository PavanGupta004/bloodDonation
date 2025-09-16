import 'package:flutter/material.dart';
import 'package:sos_blood_donation/pages/registerPages/loginPage.dart';

class SelectSignUp extends StatelessWidget {
  const SelectSignUp({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('LOGO', style: TextStyle(fontSize: 22)),
            Text(
              'SOS Blood',
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => const LoginPage(),
                  ),
                );
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.70,
                height: 120,
                decoration: BoxDecoration(color: Colors.redAccent),
                child: Center(
                  child: Text(
                    'Log In',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => const LoginPage(),
                  ),
                );
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.70,
                height: 120,
                decoration: BoxDecoration(color: Colors.white70),
                child: Center(
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
