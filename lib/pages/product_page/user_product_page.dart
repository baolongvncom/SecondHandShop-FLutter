import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_turtorial/pages/chat_pages/utils.dart';
import 'package:firebase_auth_turtorial/pages/product_page/add_product_page.dart';
import 'package:firebase_auth_turtorial/pages/product_page/user_product_detail.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class UserProductPage extends StatelessWidget {
  UserProductPage(this.userEmail, {Key? key}) : super(key: key) {
    _userProductStream = FirebaseFirestore.instance
        .collection('product_list')
        .where('sellerEmail', isEqualTo: userEmail)
        // .orderBy('time', descending: true)
        .snapshots();
  }
  String userEmail;

  //_userProductReference.get()  ---> returns Future<QuerySnapshot>
  //_userProductReference.snapshots()--> Stream<QuerySnapshot> -- realtime updates

  late Stream<QuerySnapshot> _userProductStream;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: royalBlue,
      appBar: AppBar(
        title: const Text('My Products'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddProductPage(),
                ),
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
          color: Colors.orange,
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: _userProductStream,
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

              //Check if we have data or not
              if (documents.isEmpty) {
                return const Center(child: Text('No product found'));
              }

              //Convert the documents to Maps
              List<Map> products =
                  documents.map((e) => e.data() as Map).toList();

              //Display the list
              return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (BuildContext context, int index) {
                    //Get the item at this index
                    Map thisProduct = products[index];
                    //REturn the widget for the list items
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 8.0),
                      color: Colors.blue[100],
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Image.network(
                              thisProduct['imageURL'],
                              height: 80,
                              width: 80,
                            ),
                            SizedBox(
                              width: 220,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 5.0,
                                  ),
                                  RichText(
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    text: TextSpan(
                                      text: '${thisProduct['name']}\n',
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
                                      text: '${thisProduct['price']} VND\n',
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
                            GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UserProductDetail(
                                          thisProduct['productID'],
                                          thisProduct['status']),
                                    ),
                                  );
                                },
                                child: const CircleAvatar(
                                  radius: 20,
                                  backgroundColor: royalBlue,
                                  child: Icon(
                                    // Icon chấm thang
                                    Icons.arrow_forward_ios,
                                    color: Colors.white,
                                  ),
                                ))
                          ],
                        ),
                      ),
                    );
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
