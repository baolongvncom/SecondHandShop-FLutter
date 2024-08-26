import 'dart:io';

import 'package:firebase_auth_turtorial/pages/chat_pages/utils.dart';
import 'package:firebase_auth_turtorial/pages/product_page/product_services/product_services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  // Show product

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  // Add-product initalization
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerPrice = TextEditingController();
  final TextEditingController _controllerDescription = TextEditingController();

  final ProductServices _productServices = ProductServices();

  String uniqueFileName = '';

  Reference? referenceRoot = FirebaseStorage.instance.ref();

  XFile? file;

  // Show preview product image
  String previewImageURL = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: peachColor,
        appBar: AppBar(
          backgroundColor: royalBlue,
          elevation: 0,
          title: const Text('Add an item'),
        ),
        body:
            // Add product
            Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            child: Column(
              children: [
                TextFormField(
                  controller: _controllerName,
                  decoration: const InputDecoration(
                      hintText: 'Enter the name of the item'),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the item name';
                    }

                    return null;
                  },
                ),
                TextFormField(
                  controller: _controllerPrice,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  decoration: const InputDecoration(
                      hintText: 'Enter the price of the item'),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the price if the item';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _controllerDescription,
                  decoration:
                      const InputDecoration(hintText: 'Enter the description'),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the description';
                    }

                    return null;
                  },
                ),

                // Show preview image
                if (previewImageURL != "")
                  Container(
                    width: double.infinity,
                    height: 400,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: FileImage(File(previewImageURL)),
                          fit: BoxFit.cover),
                    ),
                  ),
                if (previewImageURL == "")
                  const SizedBox(
                    width: 100,
                    height: 100,
                    child: Center(child: Text("Pick an image!")),
                  ),
                IconButton(
                    onPressed: () async {
                      ImagePicker imagePicker = ImagePicker();
                      file = await imagePicker.pickImage(
                        source: ImageSource.camera,
                        imageQuality: 25,
                      );

                      if (file == null) {
                        return;
                      }

                      setState(() {
                        previewImageURL = file!.path;
                      });

                      uniqueFileName =
                          DateTime.now().millisecondsSinceEpoch.toString();
                    },
                    icon: const Icon(Icons.camera_alt)),
                IconButton(
                    onPressed: () async {
                      ImagePicker imagePicker = ImagePicker();
                      file = await imagePicker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 25,
                      );

                      if (file == null) {
                        return;
                      }

                      setState(() {
                        previewImageURL = file!.path;
                      });

                      uniqueFileName =
                          DateTime.now().millisecondsSinceEpoch.toString();
                    },
                    icon: const Icon(Icons.photo)),

                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: royalBlue,
                    ),
                    onPressed: () async {
                      // Check null value in all controller
                      if (_controllerName.text.isEmpty ||
                          _controllerPrice.text.isEmpty ||
                          _controllerDescription.text.isEmpty ||
                          file == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 2),
                            content: Text('Please fill in all the fields'),
                          ),
                        );
                        return;
                      }

                      await _productServices.uploadProduct(
                        itemName: _controllerName.text,
                        price: int.parse(_controllerPrice.text),
                        description: _controllerDescription.text,
                        file: file,
                        context: context,
                      );

                      //Clear the TextFields
                      _controllerName.clear();
                      _controllerDescription.clear();
                      _controllerPrice.clear();

                      setState(() {
                        previewImageURL = '';
                        file = null;
                      });

                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 2),
                          content: Text('Product added successfully'),
                        ),
                      );
                    },
                    child: const Text('Submit')),
              ],
            ),
          ),
        ));
  }
}
