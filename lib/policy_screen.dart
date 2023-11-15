import 'dart:html';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:voting_app/organization_screen.dart';

class PolicyScreen extends StatefulWidget {
  final String? selectedOrganization;

  const PolicyScreen({Key? key, this.selectedOrganization}) : super(key: key);

  @override
  State<PolicyScreen> createState() => _PolicyScreenState();
}

class _PolicyScreenState extends State<PolicyScreen> {
  // List<Map<String, dynamic>> policies = [
  //   {
  //     'title': 'Policy 1',
  //     'body': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
  //     'votes': {'yes': [], 'no': [], 'abstain': []},
  //   },
  //   // Add more policies as needed
  // ];

  @override
  Widget build(BuildContext context) {
    final policyStream = FirebaseFirestore.instance
        .collection('Organizations')
        .doc(widget.selectedOrganization)
        .snapshots();
    print(widget.selectedOrganization);
    return Scaffold(
      appBar: AppBar(
        title: Text('Policy Screen'),
      ),
      body: StreamBuilder(
          stream: policyStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Failed to load posts');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            List policies = snapshot.data?['policyList'];

            print(policies);
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: policies.length,
                    itemBuilder: (context, index) {
                      final policy = policies[index];
                      return ListTile(
                        title: Text(policy['title'] as String),
                        subtitle: Text(policy['body'] as String),
                        trailing: Column(children: [
                          Text(
                              'yes ${policy['votes']['yes'].length.toString()}'),
                          Text('no ${policy['votes']['no'].length.toString()}'),
                          Text(
                              'abstain ${policy['votes']['abstain'].length.toString()}'),
                        ]),
                        onTap: () {
                          // Navigate to a detailed view of the selected policy
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PolicyDetailScreen(
                                policy: policy,
                                index: index,
                                policies: policies,
                                selectedOrganization:
                                    widget.selectedOrganization!,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (widget.selectedOrganization != null) {
                      // Show the "Create Policy" AlertDialog
                      showDialog(
                        context: context,
                        builder: (context) {
                          String title = "";
                          String body = "";
                          return AlertDialog(
                            title: Text("Create Policy"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  onChanged: (value) {
                                    title = value;
                                  },
                                  decoration:
                                      InputDecoration(labelText: 'Title'),
                                ),
                                TextField(
                                  onChanged: (value) {
                                    body = value;
                                  },
                                  decoration:
                                      InputDecoration(labelText: 'Body'),
                                ),
                                SizedBox(height: 20.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(
                                            context); // Close the dialog
                                      },
                                      child: Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // Check if title and body are not empty
                                        if (title.trim().isNotEmpty &&
                                            body.trim().isNotEmpty) {
                                          // Close the dialog
                                          Navigator.pop(context);

                                          // Save the policy data to Firestore
                                          FirebaseFirestore.instance
                                              .collection('Organizations')
                                              .doc(widget.selectedOrganization)
                                              .update({
                                            'policyList':
                                                FieldValue.arrayUnion([
                                              {
                                                'title': title,
                                                'body': body,
                                                'votes': {
                                                  'yes': [],
                                                  'no': [],
                                                  'abstain': [],
                                                },
                                              },
                                            ]),
                                          });

                                          // Optionally, you can update the local state
                                          setState(() {
                                            policies.add({
                                              'title': title,
                                              'body': body,
                                              'votes': {
                                                'yes': 0,
                                                'no': 0,
                                                'abstain': 0
                                              },
                                            });
                                          });
                                        }
                                      },
                                      child: Text("Confirm"),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    } else {
                      // Show an error message if no organization is selected
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Error"),
                            content:
                                Text("Please select an organization first."),
                          );
                        },
                      );
                    }
                  },
                  child: Text('Create Policy'),
                ),
              ],
            );
          }),
    );
  }
}

class PolicyDetailScreen extends StatelessWidget {
  final Map<String, dynamic> policy;
  final int index;
  final List policies;
  final String selectedOrganization;

  const PolicyDetailScreen(
      {Key? key,
      required this.policy,
      required this.index,
      required this.policies,
      required this.selectedOrganization})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(policy['title'] as String),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(policy['body'] as String),
          ),
          Spacer(), // This creates space above the voting buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildVotingButton('yes', index, policies, selectedOrganization),
              SizedBox(width: 8.0),
              _buildVotingButton('no', index, policies, selectedOrganization),
              SizedBox(width: 8.0),
              _buildVotingButton(
                  'abstain', index, policies, selectedOrganization),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVotingButton(
      String voteType, int index, List policies, String selectedOrganization) {
    return ElevatedButton(
      onPressed: () {
        Map updatedPolicy = policies[index];
        updatedPolicy['votes'][voteType]
            .add(FirebaseAuth.instance.currentUser!.uid);
        List updatedPolicyList = policies;
        updatedPolicyList[index] = updatedPolicy;
        // updatedPolicy = {
        //   ...policies[index],
        //   'votes': {
        //                                           'yes': [],
        //                                           'no': [],
        //                                           'abstain': [],
        //                                           voteType:
        //                                         },
        // }
        FirebaseFirestore.instance
            .collection('Organizations')
            .doc(selectedOrganization)
            .update({'policyList': updatedPolicyList});
        print('Voted $voteType');
      },
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(10.0), // Adjust the border radius as needed
        ),
        padding: EdgeInsets.all(8.0),
      ),
      child: Text(voteType),
    );
  }
}
