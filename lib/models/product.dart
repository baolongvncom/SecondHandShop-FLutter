class Product {
  String productID;
  final String name;
  int price;
  String description;
  String imageURL;
  String sellerEmail;
  String status;

  Product({
    required this.productID,
    required this.name,
    required this.price,
    required this.description,
    required this.imageURL,
    required this.sellerEmail,
    this.status = 'Available',
  });

  Map<String, dynamic> toMap() {
    return {
      'productID': productID,
      'name': name,
      'price': price,
      'description': description,
      'imageURL': imageURL,
      'sellerEmail': sellerEmail,
      'status': status,
    };
  }
}
