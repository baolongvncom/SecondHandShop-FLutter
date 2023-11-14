import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_turtorial/models/message.dart';
import 'package:flutter/material.dart';

class ChatService extends ChangeNotifier {
  // get instance of auth and firestore
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // send message method
  Future<void> sendMessage(String message, String email) async {
    // get current user
    final currentUser = _firebaseAuth.currentUser;
    final String currentEmail = currentUser?.email ?? '';
    final String currentUID = currentUser?.uid ?? '';
    final Timestamp currentTime = Timestamp.now();

    // create message object
    Message newMessage = Message(
      senderUID: currentUID,
      senderEmail: currentEmail,
      receiverEmail: email,
      message: message,
      time: currentTime,
    );

    // construct chat room id from current user and receiver email
    List<String> emailList = [currentEmail, email];
    emailList.sort();
    String chatRoomID = emailList.join('-');

    // add message to firestore
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .add(newMessage.toMap());
  }

  // get messages
  Stream<QuerySnapshot> getMessages(String senderEmail, String receiverEmail) {
    // construct chat room id from current user and receiver email
    List<String> emailList = [senderEmail, receiverEmail];
    emailList.sort();
    String chatRoomID = emailList.join('-');
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .orderBy('time', descending: true)
        .snapshots();
  }
}
