import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_turtorial/pages/Authentication%20Pages/authentication_services/authentication.dart';
import 'package:firebase_auth_turtorial/pages/chat_pages/utils.dart';
import 'package:firebase_auth_turtorial/pages/product_page/cart.dart';
import 'package:firebase_auth_turtorial/pages/product_page/orders_page.dart';
import 'package:firebase_auth_turtorial/pages/product_page/user_product_page.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class UserPage extends StatelessWidget {
  UserPage(this.userEmail, {Key? key}) : super(key: key) {
    _reference = FirebaseFirestore.instance.collection('users').doc(userEmail);
    _futureData = _reference.snapshots();
  }

  String userEmail;

  late DocumentReference _reference;

  late Stream<DocumentSnapshot> _futureData;

  late Map data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: peachColor,
      appBar: AppBar(
        title: const Text('Personal Info'),
        actions: [
          // Sign out button
          IconButton(
            onPressed: () async {
              await AuthService().signOutUser(context);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _futureData,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Some error occurred ${snapshot.error}'));
          }
          if (snapshot.hasData && snapshot.data!.exists) {
            //Get the data
            DocumentSnapshot documentSnapshot = snapshot.data;
            data = documentSnapshot.data() as Map;
            //display the data
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  // Làm cho column căn giữa
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: const [
                            BoxShadow(
                              spreadRadius: 2,
                              blurRadius: 10,
                              color: Colors.black26,
                            )
                          ],
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image:
                                Image.asset('lib/images/user_image.png').image,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Text('UserName ${data['name']}'),
                    const SizedBox(height: 20),
                    Text('UserEmail ${data['email']}'),
                    const SizedBox(height: 20),
                    // Button navigate to product page
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserProductPage(userEmail),
                          ),
                        );
                      },
                      child: const Text('My Products'),
                    ),

                    const SizedBox(height: 20),
                    // Button navigate to cart page
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Cart(userEmail),
                          ),
                        );
                      },
                      child: const Text('Cart'),
                    ),
                    const SizedBox(height: 20),
                    // Button navigate to order page
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderPage(userEmail),
                          ),
                        );
                      },
                      child: const Text('Order'),
                    ),
                  ],
                ),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
