import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';

class LoginRegisterWrapper extends StatefulWidget {
  const LoginRegisterWrapper({super.key});

  @override
  State<LoginRegisterWrapper> createState() => _LoginRegisterWrapperState();
}

class _LoginRegisterWrapperState extends State<LoginRegisterWrapper> {
  // initially show login page
  bool showLoginPage = true;

  // toggle between login and register pages
  void toggleView() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(onTap: toggleView);
    } else {
      return RegisterPage(onTap: toggleView);
    } 
  }
}