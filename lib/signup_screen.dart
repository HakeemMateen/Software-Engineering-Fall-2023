import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String errorMessage = '';

  Future<void> signUpFunction() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      print('User created: ${userCredential.user!.email}');
      // Navigate back to the sign-in page
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        setState(() {
          errorMessage = 'User already exists';
        });
      } else {
        print('Error during sign up: $e');
        // Handle other signup failures if needed
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Email Address',
              ),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Password',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: signUpFunction,
              child: Text("Sign Up"),
            ),
            SizedBox(height: 8),
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
