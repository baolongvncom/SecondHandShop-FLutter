import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_turtorial/pages/product_page/product_detail_in_cart_page.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class Cart extends StatelessWidget {
  Cart(this.userEmail, {Key? key}) : super(key: key);

  late String userEmail;

  // get user email

  //_reference.get()  ---> returns Future<QuerySnapshot>
  //_reference.snapshots()--> Stream<QuerySnapshot> -- realtime updates
  late Stream<QuerySnapshot> _stream;

  final FirebaseFirestore _reference = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final CollectionReference reference = FirebaseFirestore.instance
        .collection('cart_orders')
        .doc(userEmail)
        .collection('cart');

    _stream = reference.orderBy('time', descending: true).snapshots();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _stream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          //Check error
          if (snapshot.hasError) {
            return Center(child: Text('Some error occurred ${snapshot.error}'));
          }

          //Check if data arrived
          if (snapshot.hasData) {
            //get the data
            QuerySnapshot querySnapshot = snapshot.data;
            List<QueryDocumentSnapshot> documents = querySnapshot.docs;

            //Convert the documents to Maps
            List<Map> orders = documents.map((e) => e.data() as Map).toList();

            var productidList = orders.map((e) => e['productID']).toList();

            // Create a dictionary of productID and status
            Map<String, String> orderStatus = {};
            for (var order in orders) {
              orderStatus[order['productID']] = order['status'];
            }

            if (productidList.isEmpty) {
              return const Center(child: Text('No product in cart'));
            }

            //Display the list
            return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('product_list')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  QuerySnapshot productQuerysnapshot = snapshot.data!;
                  List<QueryDocumentSnapshot> productDocuments =
                      productQuerysnapshot.docs;

                  //Convert the documents to Maps

                  List<Map> productInCart =
                      productDocuments.map((e) => e.data() as Map).toList();

                  // Chose only the orders that are in the cart
                  Map<String, Map> productInCartMap = {};

                  bool sign = false;

                  for (var order in orders) {
                    sign = false;
                    for (var product in productInCart) {
                      if (product['productID'] == order['productID']) {
                        productInCartMap[order['productID']] = product;
                        sign = true;
                      }
                    }
                    if (sign == false) {
                      productInCartMap[order['productID']] = {
                        'productID': 'None',
                        'name': '',
                        'price': '',
                        'imageURL':
                            "https://firebasestorage.googleapis.com/v0/b/imageupload-demo-56fbe.appspot.com/o/other_images%2Fnot_available.jpg?alt=media&token=3569ecdb-8d90-4069-8754-29cea3bbf6ad",
                        'description': '',
                        'sellerEmail': '',
                        'status': 'None'
                      };
                      print(order['productID']);
                      _reference
                          .collection('cart_orders')
                          .doc(userEmail)
                          .collection('cart')
                          .doc(order['productID'])
                          .set(
                        {
                          'status': 'Product has been deleted by the seller',
                        },
                        SetOptions(merge: true),
                      );
                    }
                  }

                  return ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (BuildContext context, int index) {
                        //Get the item at this index
                        Map thisOrder = orders[index];

                        Map? thisProduct =
                            productInCartMap[thisOrder['productID']];

                        //Return the widget for the list items
                        return ListTile(
                          title: Text('${thisProduct!['name']}'),
                          subtitle: Text(
                              '${thisProduct['sellerEmail'].split('@')[0]}'),
                          trailing:
                              Text('${orderStatus[thisOrder['productID']]}'),
                          leading: SizedBox(
                              width: 50,
                              height: 200,
                              child:
                                  Image.network('${thisProduct['imageURL']}')),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ProductDetailInCart(
                                    thisOrder['productID'],
                                    orderStatus[thisOrder['productID']]!)));
                          },
                        );
                      });
                });
          }

          //Show loader
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
