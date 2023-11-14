import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_turtorial/pages/product_page/product_services/cart_order_services.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ProductDetailInSellOrder extends StatelessWidget {
  ProductDetailInSellOrder(
      this.productID, this.status, this.buyerEmail, this.orderId,
      {Key? key})
      : super(key: key) {
    _reference =
        FirebaseFirestore.instance.collection('product_list').doc(productID);
    _futureData = _reference.snapshots();
  }

  String productID;
  String status;
  String buyerEmail;
  String orderId;

  late DocumentReference _reference;

  late Stream<DocumentSnapshot> _futureData;

  late Map data;

  String code = 'Error';

  final CartAndOrder _cartAndOrder = CartAndOrder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SellOrder details'),
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
            return Center(
              child: Column(
                // Làm cho column căn giữa
                children: [
                  const SizedBox(height: 20),
                  Text('${data['name']}'),
                  const SizedBox(height: 20),
                  Text('${data['price']}'),
                  const SizedBox(height: 20),
                  Text('${data['description']}'),
                  const SizedBox(height: 20),
                  Text('BuyerEmail: $buyerEmail'),
                  const SizedBox(height: 20),
                  Text('Status: $status'),
                  const SizedBox(height: 20),
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage('${data['imageURL']}'),
                          fit: BoxFit.cover),
                    ),
                  ),
                  // Button to confirm order
                  if (status == 'Waiting for seller to confirm')
                    ElevatedButton(
                      onPressed: () async {
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
                      child: const Text('Confirm Order'),
                    ),
                  // Button to reject order
                  if (status == 'Waiting for seller to confirm')
                    ElevatedButton(
                      onPressed: () async {
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
                      child: const Text('Reject Order'),
                    ),
                  // Buttion to ship order
                  if (status == 'Order confirmed')
                    ElevatedButton(
                      onPressed: () async {
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
                      child: const Text('Ship Order'),
                    ),
                ],
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
