import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_turtorial/pages/product_page/edit_product.dart';
import 'package:firebase_auth_turtorial/pages/product_page/product_services/product_services.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class UserProductDetail extends StatelessWidget {
  UserProductDetail(this.productID, this.productStatus, {Key? key})
      : super(key: key) {
    _reference =
        FirebaseFirestore.instance.collection('product_list').doc(productID);
    _futureData = _reference.snapshots();
  }

  String productID;
  late DocumentReference _reference;

  late Stream<DocumentSnapshot> _futureData;

  late Map data;

  final ProductServices _productServices = ProductServices();

  late String productStatus;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product details'),
        actions: [
          if (productStatus == 'Available')
            IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => EditProduct(data)));
                },
                icon: const Icon(Icons.edit)),
          if (productStatus == 'Available' || productStatus == 'Sold')
            IconButton(
                onPressed: () async {
                  //Delete the item and product image
                  var code = await _productServices.deleteProduct(
                      productID: productID, context: context);

                  //Show the snackbar
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                      content: Text(code),
                    ),
                  );

                  //Go back to the previous screen
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.delete)),
        ],
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
                  Text('Seller Email: ${data['sellerEmail']}'),
                  const SizedBox(height: 20),
                  Text('Status: ${data['status']}'),
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
