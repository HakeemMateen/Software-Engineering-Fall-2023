import 'dart:html';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrganizationScreen extends StatefulWidget {
  const OrganizationScreen(
      {Key? key,
      this.selectedOrganization,
      required this.updateSelectedOrganization})
      : super(key: key);

  final String? selectedOrganization;
  final Function updateSelectedOrganization;

  @override
  State<OrganizationScreen> createState() => _OrganizationScreenState();
}

class _OrganizationScreenState extends State<OrganizationScreen> {
  final organizationNameController = TextEditingController();
  List<Map<String, dynamic>> organizations = [];

  @override
  Widget build(BuildContext context) {
    final organizationStream =
        FirebaseFirestore.instance.collection('Organizations').snapshots();
    return StreamBuilder(
      stream: organizationStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Failed to load posts');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        organizations = snapshot.data!.docs
            .map((postDoc) => postDoc.data() as Map<String, dynamic>)
            .toList();
        print(organizations);
        return Column(
          children: [
            SizedBox(
              height: 800,
              child: ListView(
                children: organizations
                    .where((element) => element['userList']
                        .contains(FirebaseAuth.instance.currentUser!.uid))
                    .map((e) => ElevatedButton(
                          onPressed: () {
                            widget.updateSelectedOrganization(e['orgName']);
                            // Navigate to an expanded view of the selected organization
                            // setState(() {
                            //   widget.selectedOrganization = e['orgName'];
                            // });
                          },
                          child: Text(e['orgName'] as String),
                        ))
                    .toList(),
              ),
            ),
            if (widget.selectedOrganization != null)
              Text(
                'Selected Organization: ${widget.selectedOrganization}',
              ),
            // Add other details or widgets related to the selected organization here
            Spacer(),

            NewWidget(
                organizationNameController: organizationNameController,
                organizations: organizations)
          ],
        );
      },
    );
  }
}

class NewWidget extends StatelessWidget {
  const NewWidget({
    Key? key,
    required this.organizationNameController,
    required this.organizations,
  }) : super(key: key);

  final TextEditingController organizationNameController;
  final List<Map<String, dynamic>> organizations;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        FloatingActionButton(
          onPressed: () {
            // Show the "Add Organization" AlertDialog
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
                            'userList': [
                              FirebaseAuth.instance.currentUser!.uid
                            ],
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
          child: Icon(Icons.add),
          backgroundColor: Color.fromARGB(255, 109, 33, 75),
          elevation: 2.0,
          tooltip: 'Add',
          heroTag: 'addOrganizationTag',
        ),
        ElevatedButton(
          onPressed: () {
            // Handle selecting the current organization
            // For simplicity, let's just print a message
            //print(
            //'Selected ${widget.selectedOrganization} as the current organization');
          },
          child: Text('Select Current Organization'),
        ),
        FloatingActionButton(
          onPressed: () {
            // Show the "Join Organization" AlertDialog
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

                          // Check if the organization exists in Firestore
                          if (organizations.any((e) =>
                              (e['orgName'] as String?)?.toLowerCase() ==
                              organizationNameController.text.toLowerCase())) {
                            // Organization exists
                            Map<String, dynamic> existingOrganization =
                                organizations.firstWhere((organization) =>
                                    (organization['orgName'] as String?)
                                        ?.toLowerCase() ==
                                    organizationNameController.text
                                        .toLowerCase());

                            // Check if the user is already a member
                            String currentUserID =
                                FirebaseAuth.instance.currentUser!.uid;
                            if (!existingOrganization['userList']
                                .contains(currentUserID)) {
                              // User is not a member, join the organization
                              List<String> userList = List<String>.from(
                                  existingOrganization['userList']);
                              userList.add(currentUserID);

                              // Update the 'userList' field in Firestore
                              FirebaseFirestore.instance
                                  .collection('Organizations')
                                  .doc(existingOrganization['orgName'])
                                  .update({'userList': userList});
                              print(
                                  "Joining organization: ${organizationNameController.text}");
                            } else {
                              // User is already a member
                              print(
                                  "User is already a member of this organization.");
                            }
                          } else {
                            // Organization does not exist, show an error message
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("Error"),
                                  content:
                                      Text("Enter a valid organization name."),
                                );
                              },
                            );
                          }
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
                      child: Text("Join"),
                    ),
                  ],
                );
              },
            );
          },
          child: Icon(Icons.person_add),
          backgroundColor: Colors.green,
          elevation: 2.0,
          tooltip: 'Join',
          heroTag: 'joinOrganizationTag',
        ),
      ],
    );
  }
}
