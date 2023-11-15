import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:voting_app/signup_screen.dart';
import 'package:voting_app/user_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final myEmailAddressController = TextEditingController();
  final myPasswordController = TextEditingController();

  Future<void> loginFunction() async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: myEmailAddressController.text,
          password: myPasswordController.text);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: ((context) => const UserHomeScreen()),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  void navigateToSignUpScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            TextField(
              controller: myEmailAddressController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Email Address',
              ),
            ),
            TextField(
              controller: myPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Password',
              ),
            ),
            OutlinedButton(onPressed: loginFunction, child: Text("Login")),
            SizedBox(height: 10),
            TextButton(
              onPressed: navigateToSignUpScreen,
              child: Text("Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
