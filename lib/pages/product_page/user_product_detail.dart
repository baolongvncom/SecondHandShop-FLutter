import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_turtorial/pages/chat_pages/utils.dart';
import 'package:firebase_auth_turtorial/pages/product_page/colors.dart';
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

  final Map<String, Color> statusColor = {
    'Available': Colors.green,
    'Not available': Colors.orange,
    'Sold': Colors.red,
  };

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
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
          return Scaffold(
            backgroundColor: peachColor,
            appBar: AppBar(
              backgroundColor: royalBlue,
              elevation: 0,
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
            body: SingleChildScrollView(
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
                        Center(
                          child: Text(
                            data['status'],
                            style: TextStyle(
                                fontSize: 20,
                                color: statusColor[data['status']],
                                fontWeight: FontWeight.w300),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child: Divider(
                            height: 2,
                          ),
                        ),
                        Row(
                          children: [
                            Text(data['name'],
                                style: const TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w500,
                                    color: royalBlue)),
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
                  )
                ],
              ),
            ),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
