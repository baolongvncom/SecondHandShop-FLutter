import 'package:cloud_firestore/cloud_firestore.dart';
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
      appBar: AppBar(
        title: const Text('Sell Orders'),
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
                        return ListTile(
                          title: Text(
                              buyerEmail[thisOrder['orderID']]!.split('@')[0]),
                          subtitle: Text('${thisProduct!['name']}'),
                          trailing:
                              Text('${orderStatus[thisOrder['orderID']]}'),
                          leading: SizedBox(
                              width: 50,
                              height: 200,
                              child:
                                  Image.network('${thisProduct['imageURL']}')),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ProductDetailInSellOrder(
                                    thisProduct['productID'],
                                    orderStatus[thisOrder['orderID']]!,
                                    buyerEmail[thisOrder['orderID']]!,
                                    orderID[thisOrder['orderID']]!)));
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
