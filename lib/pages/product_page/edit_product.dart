import 'package:firebase_auth_turtorial/pages/chat_pages/utils.dart';
import 'package:firebase_auth_turtorial/pages/product_page/product_services/product_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ignore: must_be_immutable
class EditProduct extends StatelessWidget {
  EditProduct(this._productToEdit, {Key? key}) : super(key: key) {
    _controllerName =
        TextEditingController(text: _productToEdit['name'].toString());
    _controllerPrice =
        TextEditingController(text: _productToEdit['price'].toString());
    _controllerDescription =
        TextEditingController(text: _productToEdit['description'].toString());
  }

  final Map _productToEdit;

  late TextEditingController _controllerName;
  late TextEditingController _controllerPrice;
  late TextEditingController _controllerDescription;
  final GlobalKey<FormState> _key = GlobalKey();

  // Create service to edit product
  final ProductServices _productServices = ProductServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: peachColor,
      appBar: AppBar(
        backgroundColor: royalBlue,
        title: const Text('Edit a product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _key,
          child: Column(
            children: [
              const SizedBox(
                height: 15,
              ),
              const Text(
                "Product name",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const Divider(
                height: 5,
                thickness: 2,
              ),
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
              const SizedBox(
                height: 30,
              ),
              const Text(
                "Product price",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const Divider(
                height: 5,
                thickness: 2,
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
                    return 'Please enter the item price';
                  }

                  return null;
                },
              ),
              const SizedBox(
                height: 30,
              ),
              const Text(
                "Description",
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: royalBlue),
              ),
              const Divider(
                height: 5,
                thickness: 2,
              ),
              TextFormField(
                controller: _controllerDescription,
                decoration: const InputDecoration(
                    hintText: 'Enter the description of the item'),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the description';
                  }

                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: royalBlue,
                    ),
                    onPressed: () async {
                      if (_key.currentState!.validate()) {
                        String name = _controllerName.text;
                        int price = int.parse(_controllerPrice.text);
                        String description = _controllerDescription.text;

                        var code = await _productServices.editProduct(
                          productID: _productToEdit['productID'],
                          name: name,
                          price: price,
                          description: description,
                          context: context,
                        );
                        // show the snackbar
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                            content: Text(code),
                          ),
                        );

                        // return to the previous screen
                        // ignore: use_build_context_synchronously
                      }
                    },
                    child: const Text('Submit')),
              )
            ],
          ),
        ),
      ),
    );
  }
}
