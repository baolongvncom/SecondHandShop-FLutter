import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_turtorial/pages/chat_pages/chat_page.dart';
import 'package:firebase_auth_turtorial/pages/chat_pages/utils.dart';
import 'package:firebase_auth_turtorial/pages/product_page/colors.dart';
import 'package:firebase_auth_turtorial/pages/product_page/product_services/cart_order_services.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

// ignore: must_be_immutable
class ProductDetail extends StatelessWidget {
  ProductDetail(this.productID, this.sellerEmail, {Key? key})
      : super(key: key) {
    _reference =
        FirebaseFirestore.instance.collection('product_list').doc(productID);
    _futureData = _reference.snapshots();
    userEmail = FirebaseAuth.instance.currentUser!.email!;
  }

  String productID;
  String sellerEmail;
  late DocumentReference _reference;

  late Stream<DocumentSnapshot> _futureData;

  late Map data;

  // Make a map to store text color with key is the status
  final Map<String, Color> statusColor = {
    'Available': Colors.green,
    'Sold': Colors.red,
    'Not available': Colors.orange,
  };

  final Map<String, String> statusInCart = {
    'Available': 'Add to cart',
    'Sold': 'Product has been sold',
    'Not available': 'Product is not available',
  };

  // get current user email
  String userEmail = '';

  final CartAndOrder _cartAndOrder = CartAndOrder();

  @override
  Widget build(BuildContext context) {
    userEmail = FirebaseAuth.instance.currentUser!.email!;
    return SafeArea(
      // appBar: AppBar(
      //   title: const Text('Product details'),
      //   leading: IconButton(
      //     icon: const Icon(
      //       Icons.arrow_back,
      //       color: Colors.white,
      //     ),
      //     onPressed: () => Navigator.pop(context),
      //   ),
      //   actions: [
      //     if (sellerEmail != _firebaseAuth.currentUser?.email)
      //       IconButton(
      //           onPressed: () {
      //             Navigator.push(
      //               context,
      //               MaterialPageRoute(
      //                 builder: (context) =>
      //                     ChatPage(receiverUserEmail: sellerEmail),
      //               ),
      //             );
      //           },
      //           icon: const Icon(Icons.chat)),
      //     // IconButton(
      //     //     onPressed: () async {
      //     //       // Add to cart
      //     //       String code = await _cartAndOrder.addToCart(
      //     //           productID); // productID is the id of the product that you want to add to cart
      //     //       // ignore: use_build_context_synchronously
      //     //       ScaffoldMessenger.of(context).showSnackBar(
      //     //         SnackBar(
      //     //           behavior: SnackBarBehavior.floating,
      //     //           duration: const Duration(seconds: 2),
      //     //           content: Text(code),
      //     //         ),
      //     //       );

      //     //       //Go back to the previous screen
      //     //       // ignore: use_build_context_synchronously
      //     //       Navigator.of(context).pop();
      //     //     },
      //     //     icon: const Icon(Icons.add_shopping_cart))
      //     IconButton(
      //       icon: SvgPicture.asset("assets/icons/cart.svg"),
      //       onPressed: () {
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(
      //             builder: (context) => Cart(userEmail),
      //           ),
      //         );
      //       },
      //     ),
      //   ],
      // ),
      child: StreamBuilder<DocumentSnapshot>(
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
            return Scaffold(
              floatingActionButton: FloatingActionButton.extended(
                backgroundColor: statusColor[data['status']]!,
                // make the button rounded
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                autofocus: true,
                onPressed: () async {
                  if (data['status'] == 'Available')
                  // Add to cart
                  {
                    String code = await _cartAndOrder.addToCart(
                        productID); // productID is the id of the product that you want to add to cart
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                        content: Text(code),
                      ),
                    );
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                  } else if (data['status'] == 'Sold') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                        content: Text('This product is sold'),
                      ),
                    );
                  } else if (data['status'] == 'Not available') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                        content: Text('This product is not available'),
                      ),
                    );
                  }
                },
                label: Text(statusInCart[data['status']]!),
                icon: const Icon(Icons.add_shopping_cart),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
              body: Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Image.network(data['imageURL']),
                  ),
                  buttonArrow(context),
                  scroll(
                    data['name'],
                    data['sellerEmail'].split('@')[0],
                    data['description'],
                    data['price'].toString(),
                    data['status'],
                  ),
                ],
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
    // Make add to cart button with elevated button
  }

  buttonArrow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          clipBehavior: Clip.hardEdge,
          height: 55,
          width: 55,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
          ),
          child: Container(
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Colors.transparent,
            ),
            child: const Icon(
              Icons.arrow_back_ios,
              size: 40,
              color: royalBlue,
            ),
          ),
        ),
      ),
    );
  }

  scroll(
    String name,
    String sellerName,
    String description,
    String price,
    String status,
  ) {
    return DraggableScrollableSheet(
        initialChildSize: 0.4,
        maxChildSize: 1.0,
        minChildSize: 0.4,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(
              color: peachColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 5,
                          width: 35,
                          color: Colors.black12,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    name,
                    style: Theme.of(context).textTheme.headline2,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "$price VND",
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                        color: mainText),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      InkWell(
                        onTap: () {},
                        child: const CircleAvatar(
                          radius: 25,
                          backgroundImage:
                              AssetImage("lib/images/user_image.png"),
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        sellerName,
                        style: Theme.of(context)
                            .textTheme
                            .headline3!
                            .copyWith(color: mainText),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ChatPage(receiverUserEmail: sellerEmail),
                            ),
                          );
                        },
                        child: const CircleAvatar(
                          radius: 25,
                          backgroundColor: royalBlue,
                          child: Icon(
                            IconlyLight.chat,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Divider(
                      height: 4,
                    ),
                  ),
                  const Text(
                    "Description",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    description,
                    style: const TextStyle(
                        fontSize: 20,
                        color: mainText,
                        fontWeight: FontWeight.w300),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Divider(
                      height: 4,
                    ),
                  ),
                  const Text(
                    "Status",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    status,
                    style: TextStyle(
                        fontSize: 20,
                        color: statusColor[status],
                        fontWeight: FontWeight.w300),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Divider(
                      height: 4,
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
