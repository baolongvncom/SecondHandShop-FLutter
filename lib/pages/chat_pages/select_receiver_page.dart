// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_turtorial/pages/chat_pages/chat_page.dart';
import 'package:firebase_auth_turtorial/pages/chat_pages/utils.dart';
import 'package:flutter/material.dart';

class SelectReceiverPage extends StatefulWidget {
  SelectReceiverPage({super.key});
  @override
  State<SelectReceiverPage> createState() => _SelectReceiverPageState();
}

class _SelectReceiverPageState extends State<SelectReceiverPage> {
  // instance of auth service
  final FirebaseAuth _authService = FirebaseAuth.instance;

  // current user
  final user = FirebaseAuth.instance.currentUser;

  bool isLoadingCircle = false;
  @override
  Widget build(BuildContext context) {
    return buildUserList();
  }

  // build a list of users except for the current user
  Widget buildUserList() {
    return Scaffold(
      backgroundColor: royalBlue,
      appBar: AppBar(
        backgroundColor: royalBlue,
        elevation: 0,
        title: const Text(
          'Select Receiver',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        // make the container curved
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
          color: Colors.orange,
        ),
        // make the container orange

        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            // if there is error
            if (snapshot.hasError) {
              return const Center(
                child: Text('Something went wrong'),
              );
            }
            // if it's loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Text('Loading....'),
              );
            }
            // if there is data
            return ListView(
              children: snapshot.data!.docs
                  .map<Widget>((doc) => _buildUserListItems(doc))
                  .toList(),
            );
          },
        ),
      ),
    );
  }

  // build user list items
  Widget _buildUserListItems(DocumentSnapshot document) {
    Map<String, dynamic> data =
        document.data()! as Map<String, dynamic>; // cast to map

    // display all users except for the current user
    if (_authService.currentUser!.email != data['email']) {
      return Card(
        // make each card far apart
        margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
        color: Colors.blue[100],
        elevation: 1.0,
        // make the card curved
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),

        // title: Text(data['email'].split('@')[0]),
        // onTap: () {
        //   // pass the clicked user's email to the chat page
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => ChatPage(
        //         receiverUserEmail: data['email'],
        //       ),
        //     ),
        //   );
        // },
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: [
              Image.asset(
                'lib/images/user_image.png',
                height: 80,
                width: 80,
              ),
              SizedBox(
                width: 130,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 5.0,
                    ),
                    RichText(
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      text: TextSpan(
                        text: '${data['email'].split('@')[0]}\n',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          receiverUserEmail: data['email'],
                        ),
                      ),
                    );
                  },
                  child: const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.lightBlue,
                    child: Icon(
                      Icons.message,
                      color: Colors.white,
                    ),
                  ))
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}
