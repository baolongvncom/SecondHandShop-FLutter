import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_turtorial/pages/chat_pages/utils.dart';
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

    _stream = reference.orderBy('time', descending: false).snapshots();
    return Scaffold(
      backgroundColor: royalBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Cart'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
          color: Colors.orange,
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: _stream,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            //Check error
            if (snapshot.hasError) {
              return Center(
                  child: Text('Some error occurred ${snapshot.error}'));
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
                          'name': 'Product has been deleted',
                          'price': '',
                          'imageURL':
                              "https://firebasestorage.googleapis.com/v0/b/imageupload-demo-56fbe.appspot.com/o/other_images%2Fnot_available.jpg?alt=media&token=3569ecdb-8d90-4069-8754-29cea3bbf6ad",
                          'description': '',
                          'sellerEmail': '',
                          'status': ''
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
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ProductDetailInCart(
                                      thisOrder['productID'],
                                      orderStatus[thisOrder['productID']]!)));
                            },
                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 10.0),
                              color: Colors.blue[100],
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Image.network(
                                      thisProduct?['imageURL'],
                                      height: 80,
                                      width: 80,
                                    ),
                                    if (thisProduct?['productID'] == 'None')
                                      SizedBox(
                                        width: 270,
                                        child: Text(
                                          thisProduct?['name'],
                                        ),
                                      ),
                                    if (thisProduct?['productID'] != 'None')
                                      SizedBox(
                                        width: 180,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(
                                              height: 5.0,
                                            ),
                                            RichText(
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              text: TextSpan(
                                                text:
                                                    '${thisProduct?['name']}\n',
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20.0,
                                                ),
                                              ),
                                            ),
                                            // Make rich text to show the price
                                            RichText(
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              text: TextSpan(
                                                text:
                                                    '${thisProduct?['sellerEmail'].split('@')[0]}\n',
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w100,
                                                  fontSize: 20.0,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (thisProduct?['status'] != '')
                                      SizedBox(
                                        width: 80,
                                        child: Text(
                                          thisProduct?['status'],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        });
                  });
            }

            //Show loader
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
