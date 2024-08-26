import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_turtorial/pages/chat_pages/utils.dart';
import 'package:firebase_auth_turtorial/pages/product_page/product_detail_in_sellorder.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class OrderPage extends StatelessWidget {
  OrderPage(this.userEmail, {Key? key}) : super(key: key);

  // get user email

  late DocumentReference _productReference;
  // ignore: unused_field
  late Future<DocumentSnapshot> _futureProductData;

  late String userEmail;

  // get user email

  //_reference.get()  ---> returns Future<QuerySnapshot>
  //_reference.snapshots()--> Stream<QuerySnapshot> -- realtime updates
  late Stream<QuerySnapshot> _stream;

  @override
  Widget build(BuildContext context) {
    final CollectionReference reference = FirebaseFirestore.instance
        .collection('cart_orders')
        .doc(userEmail)
        .collection('sell_orders');

    _stream = reference.orderBy('time', descending: true).snapshots();
    return Scaffold(
      backgroundColor: royalBlue,
      appBar: AppBar(
        title: const Text('Sell Orders'),
        backgroundColor: Colors.transparent,
        elevation: 0,
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

              if (orders.isEmpty) {
                return const Center(child: Text('No order found'));
              }

              // Create a dictionary of productID and status
              Map<String, String> orderStatus = {};
              Map<String, String> buyerEmail = {};
              Map<String, String> orderID = {};
              Map<String, String> productIDMap = {};
              for (var order in orders) {
                orderStatus[order['orderID']] = order['status'];
                buyerEmail[order['orderID']] = order['buyerEmail'];
                orderID[order['orderID']] = order['orderID'];
                productIDMap[order['orderID']] = order['productID'];
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

                    for (var order in orders) {
                      for (var product in productInCart) {
                        if (product['productID'] == order['productID']) {
                          productInCartMap[order['orderID']] = product;
                        }
                      }
                    }

                    return ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (BuildContext context, int index) {
                          //Get the item at this index
                          Map thisOrder = orders[index];
                          Map? thisProduct =
                              productInCartMap[thisOrder['orderID']];

                          //Return the widget for the list items
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      ProductDetailInSellOrder(
                                          thisProduct?['productID'],
                                          orderStatus[thisOrder['orderID']]!,
                                          buyerEmail[thisOrder['orderID']]!,
                                          orderID[thisOrder['orderID']]!)));
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
                                    if (buyerEmail[thisOrder['orderID']]!
                                            .split('@')[0] ==
                                        'None')
                                      SizedBox(
                                        width: 270,
                                        child: Text(
                                          thisProduct?['name'],
                                        ),
                                      ),
                                    if (buyerEmail[thisOrder['orderID']]!
                                            .split('@')[0] !=
                                        'None')
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
                                                    '${buyerEmail[thisOrder['orderID']]!.split('@')[0]}\n',
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
                                                    '${thisProduct?['name']}\n',
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
                                    if (orderStatus[thisOrder['orderID']]! !=
                                        '')
                                      SizedBox(
                                        width: 80,
                                        child: Text(
                                          orderStatus[thisOrder['orderID']]!,
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
