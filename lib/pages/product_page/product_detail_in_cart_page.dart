import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_turtorial/pages/chat_pages/chat_page.dart';
import 'package:firebase_auth_turtorial/pages/chat_pages/utils.dart';
import 'package:firebase_auth_turtorial/pages/product_page/colors.dart';
import 'package:firebase_auth_turtorial/pages/product_page/product_services/cart_order_services.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

// ignore: must_be_immutable
class ProductDetailInCart extends StatelessWidget {
  ProductDetailInCart(this.productID, this.cartStatus, {Key? key})
      : super(key: key) {
    _reference =
        FirebaseFirestore.instance.collection('product_list').doc(productID);
    _futureData = _reference.get();
  }

  final Map<String, Color> statusColor = {
    'In cart': Colors.green,
    'Sold': Colors.red,
    'Ordering': Colors.orange,
    'Seller confirmed order': Colors.blue,
    'Order rejected': Colors.red,
    'Product is being delievered': Colors.purpleAccent,
    'Product Received': Colors.greenAccent,
    'Not available': Colors.redAccent,
    'Sold out': Colors.redAccent,
  };

  // Make a FloatingActionButton map with status
  // ignore: prefer_typing_uninitialized_variables
  var floatingButtonMap = {};

  String productID;
  String cartStatus;
  late DocumentReference _reference;

  late Future<DocumentSnapshot> _futureData;

  late Map data;

  String code = 'Error';

  final CartAndOrder _cartAndOrder = CartAndOrder();

  final Map<String, String> statusInCart = {
    'In cart': 'Order',
    'Product is being delievered': 'Product Received',
    'Order rejected': 'Confirm Order Rejection',
    'Ordering': 'Cancel Order',
  };

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: _futureData,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Some error occurred ${snapshot.error}'));
        }
        if (snapshot.hasData) {
          //Get the data
          DocumentSnapshot documentSnapshot = snapshot.data;

          if (!documentSnapshot.exists) {
            return Scaffold(
                appBar: AppBar(
                  backgroundColor: royalBlue,
                  title: const Text('Product'),
                  actions: [
                    // delete from cart
                    IconButton(
                      onPressed: () async {
                        code = await _cartAndOrder.deleteFromCart(productID);
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
                      },
                      icon: const Icon(Icons.delete),
                    )
                  ],
                ),
                body: const Center(child: Text('Product has been deleted')));
          }

          data = documentSnapshot.data() as Map;
          //display the data
          return Scaffold(
            backgroundColor: peachColor,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: royalBlue,
              title: const Text('Product in cart details'),
              actions: [
                IconButton(
                  onPressed: () async {
                    code = await _cartAndOrder.deleteFromCart(productID);
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
                  },
                  icon: const Icon(Icons.delete),
                ),
              ],
            ),
            body: SingleChildScrollView(
              clipBehavior: Clip.none,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 400,
                    width: double.infinity,
                    child: Image.network(
                      data['imageURL'],
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(data['name'],
                                style: const TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w500,
                                    color: royalBlue)),
                            const Spacer(),
                            Text(
                              cartStatus,
                              style: TextStyle(
                                  fontSize: 20,
                                  color: statusColor[cartStatus],
                                  fontWeight: FontWeight.w300),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${data['price']} VND',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                              color: mainText),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child: Divider(
                            height: 2,
                          ),
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
                              data['sellerEmail'].split('@')[0],
                              style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w300,
                                  color: mainText),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatPage(
                                        receiverUserEmail: data['sellerEmail']),
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
                            height: 2,
                          ),
                        ),
                        const Text(
                          "Description",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          data['description'],
                          style: const TextStyle(
                              fontSize: 20,
                              color: mainText,
                              fontWeight: FontWeight.w300),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child: Divider(
                            height: 2,
                          ),
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              backgroundColor: royalBlue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: const BorderSide(color: royalBlue)),
              label: Text(
                statusInCart[cartStatus] == null
                    ? cartStatus
                    : statusInCart[cartStatus]!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                ),
              ),
              onPressed: () async {
                if (cartStatus == 'In cart') {
                  code = await _cartAndOrder.addToOrder(productID);
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                      content: Text(code),
                    ),
                    // navigate to order page
                  );
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                }
                if (cartStatus == 'Ordering') {
                  code = await _cartAndOrder.cancelOrder(productID);
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
                }
                if (cartStatus == 'Product is being delievered') {
                  code = await _cartAndOrder.buyerReceiveProduct(productID);
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
                }
                if (cartStatus == 'Order rejected') {
                  code =
                      await _cartAndOrder.buyerConfirmOrderRejection(productID);
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
                }
              },
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
