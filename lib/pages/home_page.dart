// ignore_for_file: prefer_const_constructors
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_turtorial/pages/chat_pages/select_receiver_page.dart';
import 'package:firebase_auth_turtorial/pages/personal_info/personal_info_page.dart';
import 'package:firebase_auth_turtorial/pages/product_page/product_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // get current user email
  String? userEmail = FirebaseAuth.instance.currentUser?.email;
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      AddItem(),
      SelectReceiverPage(),
      UserPage(userEmail!),
    ];
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          body: tabs[currentIndex],
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.blue, // Màu nền của BottomNavigationBar
            ),
            child: BottomNavigationBar(
              // make the bottom navigation bar curved

              backgroundColor: Color(0xFF4169E1),
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(
                      Icons.home,
                      color: Colors.white,
                    ),
                    label: "Home"),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.chat,
                    color: Colors.white,
                  ),
                  label: "Chat",
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                  backgroundColor: Colors.white,
                  label: "Profile",
                ),
              ],
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white54,
              currentIndex: currentIndex,
              onTap: (int index) {
                setState(() {
                  currentIndex = index;
                });
              },
            ),
          )),
    );
  }
}
