import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:voting_app/organization_screen.dart';
import 'package:voting_app/policy_screen.dart';
import 'package:voting_app/user_settings_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  late List screens;
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    screens = [
      OrganizationScreen(),
      PolicyScreen(),
      UserSettingsScreen(),
    ];
    return Scaffold(
      body: Builder(
        builder: ((context) => screens[currentIndex]),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                onPressed: () {
                  setState(() {
                    currentIndex = 0;
                  });
                },
                icon: Icon(Icons.library_add)),
            IconButton(
                onPressed: () {
                  setState(() {
                    currentIndex = 1;
                  });
                },
                icon: Icon(Icons.list)),
            IconButton(onPressed: () {}, icon: Icon(Icons.home)),
            IconButton(onPressed: () {}, icon: Icon(Icons.search)),
            IconButton(
                onPressed: () {
                  setState(() {
                    currentIndex = 2;
                  });
                },
                icon: Icon(Icons.settings))
          ],
        ),
      ),
    );
  }
}
