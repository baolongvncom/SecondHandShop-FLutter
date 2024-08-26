import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_turtorial/pages/chat_pages/chat_page.dart';
import 'package:firebase_auth_turtorial/pages/chat_pages/utils.dart';
import 'package:firebase_auth_turtorial/pages/product_page/colors.dart';
import 'package:firebase_auth_turtorial/pages/product_page/product_services/cart_order_services.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

// ignore: must_be_immutable
class ProductDetailInSellOrder extends StatelessWidget {
  ProductDetailInSellOrder(
      this.productID, this.status, this.buyerEmail, this.orderId,
      {Key? key})
      : super(key: key) {
    _reference =
        FirebaseFirestore.instance.collection('product_list').doc(productID);
    _futureData = _reference.get();
  }

  String productID;
  String status;
  String buyerEmail;
  String orderId;

  late DocumentReference _reference;

  late Future<DocumentSnapshot> _futureData;

  late Map data;

  String code = 'Error';

  final CartAndOrder _cartAndOrder = CartAndOrder();

  final Map<String, Color> statusColor = {
    'Order confirmed': Colors.green,
    'Waiting for seller to confirm': Colors.blue,
    'Order rejected': Colors.red,
    'Product is being shipped': Colors.purpleAccent,
    'Product delieverd': Colors.greenAccent,
  };

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: _futureData,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Some error occurred ${snapshot.error}'));
        }
        if (snapshot.hasData && snapshot.data.exists) {
          //Get the data
          DocumentSnapshot documentSnapshot = snapshot.data;

          //display the data
          data = documentSnapshot.data() as Map;
          return Scaffold(
            backgroundColor: peachColor,
            appBar: AppBar(
              backgroundColor: royalBlue,
              title: const Text('Sell order detail'),
              actions: [
                // delete from cart
                if (status == 'Order rejected' || status == 'Product delieverd')
                  IconButton(
                    onPressed: () async {
                      code = await _cartAndOrder.deleteFromOrder(productID);
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
            body: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                // Làm cho column căn giữa
                children: [
                  SizedBox(
                    height: 400,
                    width: double.infinity,
                    child: Image.network(
                      '${data['imageURL']}',
                      fit: BoxFit.cover,
                    ),
                  ),
                  // const SizedBox(height: 20),
                  // Text('${data['name']}'),
                  // const SizedBox(height: 20),
                  // Text('${data['price']}'),
                  // const SizedBox(height: 20),
                  // Text('${data['description']}'),
                  // const SizedBox(height: 20),
                  // Text('BuyerEmail: $buyerEmail'),
                  // const SizedBox(height: 20),
                  // Text('Status: $status'),
                  // const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Center(
                          child: Text(
                            status,
                            style: TextStyle(
                                fontSize: 20,
                                color: statusColor[status],
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child: Divider(
                            height: 2,
                            thickness: 2,
                          ),
                        ),
                        Row(
                          children: [
                            Text(data['name'],
                                style: const TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w500,
                                    color: royalBlue)),
                            const Spacer(),
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
                            thickness: 2,
                          ),
                        ),
                        const Text(
                          "Buyer's information",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
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
                              buyerEmail.split('@')[0],
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
                                    builder: (context) =>
                                        ChatPage(receiverUserEmail: buyerEmail),
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
                            thickness: 2,
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
                            thickness: 2,
                          ),
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                      ],
                    ),
                  ),
                  // // Button to confirm order
                  // if (status == 'Waiting for seller to confirm')
                  //   ElevatedButton(
                  //     onPressed: () async {
                  //       code = await _cartAndOrder.sellerConfirmOrder(orderId);
                  //       // ignore: use_build_context_synchronously
                  //       ScaffoldMessenger.of(context).showSnackBar(
                  //         SnackBar(
                  //           behavior: SnackBarBehavior.floating,
                  //           duration: const Duration(seconds: 2),
                  //           content: Text(code),
                  //         ),
                  //       );
                  //       // ignore: use_build_context_synchronously
                  //       Navigator.of(context).pop();
                  //     },
                  //     child: const Text('Confirm Order'),
                  //   ),
                  // // Button to reject order
                  // if (status == 'Waiting for seller to confirm')
                  //   ElevatedButton(
                  //     onPressed: () async {
                  //       code = await _cartAndOrder.sellerRejectOrder(orderId);
                  //       // ignore: use_build_context_synchronously
                  //       ScaffoldMessenger.of(context).showSnackBar(
                  //         SnackBar(
                  //           behavior: SnackBarBehavior.floating,
                  //           duration: const Duration(seconds: 2),
                  //           content: Text(code),
                  //         ),
                  //       );
                  //       // ignore: use_build_context_synchronously
                  //       Navigator.of(context).pop();
                  //     },
                  //     child: const Text('Reject Order'),
                  //   ),
                  // // Buttion to ship order
                  // if (status == 'Order confirmed')
                  //   ElevatedButton(
                  //     onPressed: () async {
                  //       code = await _cartAndOrder.sellerShipOrder(orderId);
                  //       // ignore: use_build_context_synchronously
                  //       ScaffoldMessenger.of(context).showSnackBar(
                  //         SnackBar(
                  //           behavior: SnackBarBehavior.floating,
                  //           duration: const Duration(seconds: 2),
                  //           content: Text(code),
                  //         ),
                  //       );
                  //       // ignore: use_build_context_synchronously
                  //       Navigator.of(context).pop();
                  //     },
                  //     child: const Text('Ship Order'),
                  //   ),
                ],
              ),
            ),
            floatingActionButton: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (status == 'Waiting for seller to confirm')
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () async {
                        code = await _cartAndOrder.sellerConfirmOrder(orderId);
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
                      child: Container(
                        decoration: BoxDecoration(
                          color: royalBlue,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        width: 160,
                        height: 50,
                        child: const Center(
                            child: Text(
                          'Confirm Order',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        )),
                      ),
                    ),
                  ),
                if (status == 'Waiting for seller to confirm')
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () async {
                        code = await _cartAndOrder.sellerRejectOrder(orderId);
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
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        width: 160,
                        height: 50,
                        child: const Center(
                          child: Text(
                            'Reject Order',
                            style: TextStyle(
                                color: Colors.orangeAccent,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (status == 'Order confirmed')
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () async {
                        code = await _cartAndOrder.sellerShipOrder(orderId);
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
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.greenAccent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        width: 160,
                        height: 50,
                        child: const Center(
                            child: Text(
                          'Ship Order',
                          style: TextStyle(color: Colors.white),
                        )),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
