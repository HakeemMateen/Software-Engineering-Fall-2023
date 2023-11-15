import 'dart:html';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class OrganizationScreen extends StatefulWidget {
  const OrganizationScreen({super.key});

  @override
  State<OrganizationScreen> createState() => _OrganizationScreenState();
}

class _OrganizationScreenState extends State<OrganizationScreen> {
  final organizationNameController = TextEditingController();
  final List<String> items = List<String>.generate(10000, (i) => 'Item $i');

  @override
  Widget build(BuildContext context) {
    final organizationStream =
        FirebaseFirestore.instance.collection('Organizations').snapshots();
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show the AlertDialog
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Enter Organization Name."),
                content: TextField(
                  controller: organizationNameController,
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                    },
                    child: Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      // Check if the organization name is not empty
                      if (organizationNameController.text.trim().isNotEmpty) {
                        // Close the dialog
                        Navigator.pop(context);

                        // Save the organization data to Firestore
                        FirebaseFirestore.instance
                            .collection('Organizations')
                            .doc(organizationNameController.text
                                .replaceAll(' ', ''))
                            .set({
                          'userList': [FirebaseAuth.instance.currentUser!.uid],
                          'policyList': [],
                          'orgRules': [],
                          'orgName': organizationNameController.text,
                        });
                      } else {
                        // Show an error message if the organization name is empty
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Error"),
                              content:
                                  Text("Organization name cannot be empty."),
                            );
                          },
                        );
                      }
                    },
                    child: Text("OK"),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add), // Change the icon as needed
        backgroundColor: Colors.blue, // Change the background color as needed
        elevation: 2.0, // Change the elevation as needed
        tooltip: 'Add', // Add a tooltip if desired
        heroTag: 'yourUniqueTag', // Add a unique heroTag if using multiple FABs
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      body: StreamBuilder(
        stream: organizationStream,
        builder: (context, snapshot) {
          //print(snapshot);
          if (snapshot.hasError) {
            return const Text('Failed to load posts');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          List organizations =
              snapshot.data!.docs.map((postDoc) => postDoc.data()).toList();
          print(organizations);
          return Column(
            children: [
              SizedBox(
                height: 100,
                child: ListView(
                  children:
                      organizations.map((e) => Text(e['orgName'])).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
