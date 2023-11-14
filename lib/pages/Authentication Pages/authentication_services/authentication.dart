import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../services/notify_messages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  // instance of firestore
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  // sign-in state
  static bool isSignedIn = false;

  // instance of firebase auth
  final FirebaseAuth _fireBaseAuth = FirebaseAuth.instance;

  static final StreamController<bool> _streamController =
      StreamController<bool>();
  static Stream<bool> get counterStream => _streamController.stream;

  static Future<void> setSignInState(bool state) async {
    isSignedIn = state;
    _streamController.sink.add(state);
  }

  // sign user in method
  Future<bool> signInUser(
      String email, String password, BuildContext context) async {
    // try sign in
    try {
      UserCredential userCredential =
          await _fireBaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // add user to firestore
      await _fireStore.collection('users').doc(userCredential.user?.email).set(
        {
          'email': email,
          'password': password,
          'name': email.split('@')[0],
        },
        SetOptions(merge: true),
      );
      return true;
    } on FirebaseAuthException catch (e) {
      // show error message
      showErrorMessage(context, e.code);
      return false;
    }
  }

  // sign user out method
  Future<void> signOutUser(BuildContext context) async {
    try {
      await _fireBaseAuth.signOut();
      await setSignInState(false);
    } on FirebaseAuthException catch (e) {
      // show error message
      showErrorMessage(context, e.code);
    }
  }

  // register user method
  Future<bool> registerUser(
      String email, String password, BuildContext context) async {
    // try register
    try {
      UserCredential userCredential =
          await _fireBaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // create user document
      await _fireStore.collection('users').doc(userCredential.user?.email).set({
        'email': email,
        'password': password,
        'name': email.split('@')[0],
      });

      return true;
    } on FirebaseAuthException catch (e) {
      // show error message
      showErrorMessage(context, e.code);

      return false;
    }
  }
}
