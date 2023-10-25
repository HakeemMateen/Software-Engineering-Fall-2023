import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
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
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Password',
              ),
            ),
            OutlinedButton(onPressed: loginFunction, child: Text("Login"))
          ],
        ),
      ),
    );
  }
}
