// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:firebase_auth_turtorial/models/product.dart';
import 'package:firebase_auth_turtorial/services/notify_messages.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class ProductServices {
  final FirebaseFirestore _reference = FirebaseFirestore.instance;

  String imageURL = '';
  String uniqueFileName = '';

  Reference? referenceRoot = FirebaseStorage.instance.ref();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  late Future<DocumentSnapshot> _futureData;

  String userEmail = '';

  ProductServices() {
    userEmail = _firebaseAuth.currentUser?.email ?? '';
  }

  // Upload product
  Future<String> uploadProduct({
    XFile? file,
    required String itemName,
    int price = 0,
    String description = 'None',
    required BuildContext context,
  }) async {
    if (file != null) {
      final currentUser = _firebaseAuth.currentUser;

      String sellerEmail = currentUser?.email ?? '';

      uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();

      Reference? referenceDirImage = referenceRoot?.child('product_images');

      Reference referenceImageFile =
          referenceDirImage!.child('$uniqueFileName.png');

      try {
        await referenceImageFile.putFile(File(file.path));

        imageURL = await referenceImageFile.getDownloadURL();
      } on FirebaseException catch (e) {
        showErrorMessage(context, e.code);
      }

      Product dataToSend = Product(
        productID: uniqueFileName.toString(),
        name: itemName,
        price: price,
        description: description,
        imageURL: imageURL,
        sellerEmail: sellerEmail,
      );
      // Add to product list

      await _reference
          .collection('product_list')
          .doc(uniqueFileName.toString())
          .set(
            dataToSend.toMap(),
            SetOptions(merge: true),
          );
      // Add to user's product list
      await _reference
          .collection('user_product_list')
          .doc(sellerEmail)
          .collection('product_list')
          .doc(uniqueFileName.toString())
          .set({
        'productID': uniqueFileName.toString(),
      });
    }
    return 'Product uploaded successfully';
  }

  // Delete product
  Future<String> deleteProduct({
    required String productID,
    required BuildContext context,
  }) async {
    DocumentReference deleteProductReference =
        _reference.collection('product_list').doc(productID);

    // Get imageURL

    _futureData = deleteProductReference.get();
    DocumentSnapshot documentSnapshot = await _futureData;
    Map data = documentSnapshot.data() as Map;
    String imageURL = data['imageURL'];
    String productStatus = data['status'];

    if (productStatus != 'Available' && productStatus != 'Sold') {
      return 'Cannot delete this product';
    }

    // Update status in buyer cart
    QuerySnapshot orderQuerySnapshot = await _reference
        .collection('cart_orders')
        .doc(userEmail)
        .collection('sell_orders')
        .where('productID', isEqualTo: productID)
        .get();

    Timestamp currentTime = Timestamp.now();

    await Future.forEach(orderQuerySnapshot.docs, (element) async {
      // element to map
      Map<String, dynamic> elementMap = element.data() as Map<String, dynamic>;
      await _reference
          .collection('cart_orders')
          .doc(elementMap['buyerEmail'])
          .collection('cart')
          .doc(elementMap['productID'])
          .set(
        {
          'status': 'Product has been deleted by the seller',
          'time': currentTime,
        },
        SetOptions(merge: true),
      );

      // Delete from seller's sell_orders
      await _reference
          .collection('cart_orders')
          .doc(userEmail)
          .collection('sell_orders')
          .doc(elementMap['orderID'])
          .delete();
    });

    //

    // Delete product
    await deleteProductReference.delete();
    await _firebaseStorage.refFromURL(imageURL).delete();

    return 'Product deleted successfully';
  }

  // Edit product
  Future<String> editProduct({
    required String productID,
    required String name,
    int price = 0,
    String description = 'None',
    required BuildContext context,
  }) async {
    _futureData = _reference.collection('product_list').doc(productID).get();
    DocumentSnapshot documentSnapshot = await _futureData;
    Map data = documentSnapshot.data() as Map;
    String productStatus = data['status'];

    if (productStatus != 'Available') {
      return 'Cannot edit this product';
    }

    await _reference.collection('product_list').doc(productID).set(
      {
        'name': name,
        'price': price,
        'description': description,
      },
      SetOptions(merge: true),
    );
    return 'Product edited successfully';
  }
}
