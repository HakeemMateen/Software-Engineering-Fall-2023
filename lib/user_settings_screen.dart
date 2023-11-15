import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:voting_app/login_screen.dart';

class UserSettingsScreen extends StatefulWidget {
  const UserSettingsScreen({super.key});

  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  Future<void> logoutFunction() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: ((context) => const LoginScreen())),
        (route) => false);
  }

  Future<void> deleteAccountFunction() async {
    try {
      // Get the current user
      User? user = FirebaseAuth.instance.currentUser;

      // Delete the user's account
      await user?.delete();

      // Navigate to the login screen
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: ((context) => const LoginScreen())),
          (route) => false);
    } on FirebaseAuthException catch (e) {
      print('Error deleting account: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            OutlinedButton(onPressed: logoutFunction, child: const Text("Logout")),
            OutlinedButton(onPressed: deleteAccountFunction, child: const Text("Delete Account"))
          ],
        ),
      ),
    );
  }
}
