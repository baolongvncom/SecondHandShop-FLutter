import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_turtorial/pages/product_page/product_detail.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ProductList extends StatelessWidget {
  ProductList({Key? key}) : super(key: key) {
    _stream = _reference.snapshots();
  }

  final CollectionReference _reference =
      FirebaseFirestore.instance.collection('product_list');

  //_reference.get()  ---> returns Future<QuerySnapshot>
  //_reference.snapshots()--> Stream<QuerySnapshot> -- realtime updates
  late Stream<QuerySnapshot> _stream;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
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

          //Check if we have data or not
          if (documents.isEmpty) {
            return const Center(child: Text('No product found'));
          }

          //Convert the documents to Maps
          List<Map> products = documents.map((e) => e.data() as Map).toList();

          //Display the list
          return ListView.builder(
              itemCount: products.length,
              itemBuilder: (BuildContext context, int index) {
                //Get the item at this index
                Map thisProduct = products[index];
                //REturn the widget for the list items
                return ListTile(
                  title: Text('${thisProduct['name']}'),
                  subtitle: Text('${thisProduct['price']} VND'),
                  leading: Container(
                    width: 50,
                    height: 200,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(0),
                        image: DecorationImage(
                          image: NetworkImage('${thisProduct['imageURL']}'),
                          fit: BoxFit.cover,
                        )),
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ProductDetail(
                            thisProduct['productID'],
                            thisProduct['sellerEmail'])));
                  },
                );
              });
        }

        //Show loader
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
