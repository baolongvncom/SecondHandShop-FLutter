// ignore_for_file: prefer_const_constructors
import 'package:firebase_auth_turtorial/pages/home_page.dart';
import 'package:firebase_auth_turtorial/pages/Authentication%20Pages/authentication_services/authentication.dart';
import 'package:flutter/material.dart';
import 'login_register_wrapper.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<bool>(
        stream: AuthService.counterStream,
        builder: (context, snapshot) {
          // user is logged in
          if (snapshot.data == true) {
            return HomePage();
          }
          // user is not logged in
          else {
            return LoginRegisterWrapper();
          }
        },
      ),
    );
  }
}
