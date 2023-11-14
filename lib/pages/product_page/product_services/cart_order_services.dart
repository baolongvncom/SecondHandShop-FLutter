import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartAndOrder {
  // instances
  final FirebaseFirestore _fireSotreReference = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  late DocumentReference _orderReference;
  late Future<DocumentSnapshot> _futureOrderData;

  late DocumentReference _productReference;
  late Future<DocumentSnapshot> _futureProductData;

  String sellerEmail = '';
  String buyerEmail = '';
  String productStatus = '';
  late Timestamp currentTime;
  String userEmail = '';

  CartAndOrder() {
    // get current user
    final currentUser = _firebaseAuth.currentUser;
    // get user email
    userEmail = currentUser?.email ?? '';
    // get all order in cart
  }

  // add product to cart
  Future<String> addToCart(String productID) async {
    _orderReference = FirebaseFirestore.instance
        .collection('cart_orders')
        .doc(userEmail)
        .collection('cart')
        .doc(productID);

    _productReference =
        FirebaseFirestore.instance.collection('product_list').doc(productID);
    _futureProductData = _productReference.get();

    await _futureProductData.then((value) {
      sellerEmail = value['sellerEmail'];
      productStatus = value['status'];
    });

    if (userEmail == sellerEmail) {
      return 'Cannot add your own product to cart';
    }

    if (productStatus == 'Not available') {
      await _orderReference.set(
        {
          'status': 'In cart',
          'time': currentTime,
        },
        SetOptions(merge: true),
      );

      return 'Product not available';
    }

    if (productStatus == 'Sold') {
      return 'Product has been sold';
    }

    var orderID = DateTime.now().millisecondsSinceEpoch.toString();
    currentTime = Timestamp.now();

    // check if product already in cart

    _futureOrderData = _orderReference.get();

    await _futureOrderData.then((value) {
      if (value.exists) {
        return 'Product already in cart';
      }
    });

    // add product to user cart
    await _fireSotreReference
        .collection('cart_orders')
        .doc(userEmail)
        .collection('cart')
        .doc(productID)
        .set(
      {
        'productID': productID,
        'orderID': orderID,
        'sellerEmail': sellerEmail,
        'status': 'In cart',
        'time': currentTime,
      },
      SetOptions(merge: true),
    );

    return 'Product added to cart';
  }

  // add product from cart to order
  Future<String> addToOrder(String productID) async {
    currentTime = Timestamp.now();
    String orderID = '';
    // get current user
    final currentUser = _firebaseAuth.currentUser;

    // get user email
    String userEmail = currentUser?.email ?? '';

    // get seller email product status
    _orderReference = FirebaseFirestore.instance
        .collection('cart_orders')
        .doc(userEmail)
        .collection('cart')
        .doc(productID);
    _futureOrderData = _orderReference.get();

    await _futureOrderData.then((value) {
      sellerEmail = value['sellerEmail'];
      orderID = value['orderID'];
    });

    // check product status
    _orderReference =
        FirebaseFirestore.instance.collection('product_list').doc(productID);
    _futureOrderData = _orderReference.get();
    await _futureOrderData.then((value) {
      productStatus = value['status'];
    });

    if (productStatus == 'Not available') {
      return 'Product Not Available';
    }

    if (productStatus == 'Sold') {
      return 'Product has been sold';
    }
    
    // update user order status
    await _fireSotreReference
        .collection('cart_orders')
        .doc(userEmail)
        .collection('cart')
        .doc(productID)
        .set(
      {
        'status': 'Ordering',
        'time': currentTime,
      },
      SetOptions(merge: true),
    );

    // add product to seller sell_orders
    await _fireSotreReference
        .collection('cart_orders')
        .doc(sellerEmail)
        .collection('sell_orders')
        .doc(orderID)
        .set(
      {
        'productID': productID,
        'buyerEmail': userEmail,
        'status': 'Waiting for seller to confirm',
        'time': currentTime,
        'orderID': orderID,
      },
      SetOptions(merge: true),
    );

    return 'Order placed';
  }

  // delete product from cart
  Future<String> deleteFromCart(String productID) async {
    String orderStatus = '';

    _orderReference = FirebaseFirestore.instance
        .collection('cart_orders')
        .doc(userEmail)
        .collection('cart')
        .doc(productID);
    _futureOrderData = _orderReference.get();

    await _futureOrderData.then((value) {
      orderStatus = value['status'];
    });

    if (orderStatus != 'In cart' &&
        orderStatus != 'Order rejected' &&
        orderStatus != 'Product has been deleted by the seller' &&
        orderStatus != 'Product Received') {
      return 'Can not delete product from cart';
    }

    // delete product from user cart
    await _fireSotreReference
        .collection('cart_orders')
        .doc(userEmail)
        .collection('cart')
        .doc(productID)
        .delete();

    return 'Product deleted from cart';
  }

  // seller reject order
  Future<String> sellerRejectOrder(String orderID) async {
    String productID = '';
    String orderStatus = '';
    // get buyer email and product id
    _orderReference = FirebaseFirestore.instance
        .collection('cart_orders')
        .doc(userEmail)
        .collection('sell_orders')
        .doc(orderID);
    _futureOrderData = _orderReference.get();

    await _futureOrderData.then((value) {
      buyerEmail = value['buyerEmail'];
      productID = value['productID'];
      orderStatus = value['status'];
    });

    if (orderStatus != 'Waiting for seller to confirm') {
      return 'Order not in waiting status';
    }

    currentTime = Timestamp.now();

    // seller (user) confirm sell order
    await _fireSotreReference
        .collection('cart_orders')
        .doc(userEmail)
        .collection('sell_orders')
        .doc(orderID)
        .set(
      {
        'status': 'Order rejected',
        'time': currentTime,
      },
      SetOptions(merge: true),
    );

    // confirm buyer order
    await _fireSotreReference
        .collection('cart_orders')
        .doc(buyerEmail)
        .collection('cart')
        .doc(productID)
        .set(
      {
        'status': 'Order rejected',
        'time': currentTime,
      },
      SetOptions(merge: true),
    );

    return 'Order rejected';
  }

  // seller confirm order
  Future<String> sellerConfirmOrder(String orderID) async {
    // get current user

    String productID = '';
    String orderStatus = '';

    // get user email

    // get buyer email and product id
    _orderReference = FirebaseFirestore.instance
        .collection('cart_orders')
        .doc(userEmail)
        .collection('sell_orders')
        .doc(orderID);
    _futureOrderData = _orderReference.get();

    await _futureOrderData.then((value) {
      buyerEmail = value['buyerEmail'];
      productID = value['productID'];
      orderStatus = value['status'];
    });

    if (orderStatus != 'Waiting for seller to confirm') {
      return 'Order not in waiting status';
    }

    currentTime = Timestamp.now();

    // seller (user) confirm sell order
    await _fireSotreReference
        .collection('cart_orders')
        .doc(userEmail)
        .collection('sell_orders')
        .doc(orderID)
        .set(
      {
        'status': 'Order confirmed',
        'time': currentTime,
      },
      SetOptions(merge: true),
    );

    // confirm buyer order
    await _fireSotreReference
        .collection('cart_orders')
        .doc(buyerEmail)
        .collection('cart')
        .doc(productID)
        .set(
      {
        'status': 'Seller confirmed order',
        'time': currentTime,
      },
      SetOptions(merge: true),
    );
    // change other order status to 'Order rejected'
    QuerySnapshot otherOrderQuerySnapshot = await _fireSotreReference
        .collection('cart_orders')
        .doc(userEmail)
        .collection('sell_orders')
        .where('status', isEqualTo: 'Waiting for seller to confirm')
        .get();
    await Future.forEach(otherOrderQuerySnapshot.docs, (element) async {
      // element to map
      Map<String, dynamic> elementMap = element.data() as Map<String, dynamic>;
      await _fireSotreReference
          .collection('cart_orders')
          .doc(elementMap['buyerEmail'])
          .collection('cart')
          .doc(elementMap['productID'])
          .set(
        {
          'status': 'Order rejected',
          'time': currentTime,
        },
        SetOptions(merge: true),
      );
    });

    // change other order status in sell orders to 'Order canceled'
    otherOrderQuerySnapshot = await _fireSotreReference
        .collection('cart_orders')
        .doc(userEmail)
        .collection('sell_orders')
        .where('status', isEqualTo: 'Waiting for seller to confirm')
        .get();
    await Future.forEach(otherOrderQuerySnapshot.docs, (element) async {
      // element to map
      Map<String, dynamic> elementMap = element.data() as Map<String, dynamic>;
      await _fireSotreReference
          .collection('cart_orders')
          .doc(userEmail)
          .collection('sell_orders')
          .doc(elementMap['orderID'])
          .set(
        {
          'status': 'Order rejected',
          'time': currentTime,
        },
        SetOptions(merge: true),
      );
    });

    // change product status
    await _fireSotreReference.collection('product_list').doc(productID).set(
      {
        'status': 'Not available',
      },
      SetOptions(merge: true),
    );

    return 'Order confirmed';
  }

  // delete product from order
  Future<String> deleteFromOrder(String productID) async {
    String orderStatus = '';

    // get current user
    final currentUser = _firebaseAuth.currentUser;

    // get user email
    String userEmail = currentUser?.email ?? '';

    _orderReference = FirebaseFirestore.instance
        .collection('cart_orders')
        .doc(userEmail)
        .collection('cart')
        .doc(productID);
    _futureOrderData = _orderReference.get();

    await _futureOrderData.then((value) {
      orderStatus = value['status'];
    });

    if (orderStatus != 'In cart') {
      return 'Can not delete product from buyer orders';
    }

    // delete product from user cart
    await _fireSotreReference
        .collection('cart_orders')
        .doc(userEmail)
        .collection('sell_orders')
        .doc(productID)
        .delete();

    return 'Order deleted';
  }

  // seller ship order
  Future<String> sellerShipOrder(String orderID) async {
    String productID = '';
    String orderStatus = '';

    // get buyer email and product id
    _orderReference = FirebaseFirestore.instance
        .collection('cart_orders')
        .doc(userEmail)
        .collection('sell_orders')
        .doc(orderID);
    _futureOrderData = _orderReference.get();

    await _futureOrderData.then((value) {
      buyerEmail = value['buyerEmail'];
      productID = value['productID'];
      orderStatus = value['status'];
    });

    if (orderStatus != 'Order confirmed') {
      return 'Order not in confirmed status';
    }

    currentTime = Timestamp.now();

    // seller (user) confirm sell order
    await _fireSotreReference
        .collection('cart_orders')
        .doc(userEmail)
        .collection('sell_orders')
        .doc(orderID)
        .set(
      {
        'status': 'Product is being shipped',
        'time': currentTime,
      },
      SetOptions(merge: true),
    );

    // confirm buyer cart
    await _fireSotreReference
        .collection('cart_orders')
        .doc(buyerEmail)
        .collection('cart')
        .doc(productID)
        .set(
      {
        'status': 'Product is being delievered',
        'time': currentTime,
      },
      SetOptions(merge: true),
    );
    return 'Order shipped';
  }

  // buyer receive order
  Future<String> buyerReceiveProduct(String productID) async {
    // get current user

    String orderID = '';
    String orderStatus = '';

    // get user email

    // get seller email and product id
    _orderReference = FirebaseFirestore.instance
        .collection('cart_orders')
        .doc(userEmail)
        .collection('cart')
        .doc(productID);
    _futureOrderData = _orderReference.get();

    await _futureOrderData.then((value) {
      sellerEmail = value['sellerEmail'];
      orderID = value['orderID'];
      orderStatus = value['status'];
    });

    if (orderStatus != 'Product is being delievered') {
      return 'Product not in delievering status';
    }

    currentTime = Timestamp.now();

    // seller (user) confirm sell order
    await _fireSotreReference
        .collection('cart_orders')
        .doc(sellerEmail)
        .collection('sell_orders')
        .doc(orderID)
        .set(
      {
        'status': 'Product delieverd',
        'time': currentTime,
      },
      SetOptions(merge: true),
    );

    // confirm buyer cart
    await _fireSotreReference
        .collection('cart_orders')
        .doc(userEmail)
        .collection('cart')
        .doc(productID)
        .set(
      {
        'status': 'Product Received',
        'time': currentTime,
      },
      SetOptions(merge: true),
    );

    // change product status
    await _fireSotreReference.collection('product_list').doc(productID).set(
      {
        'status': 'Sold',
      },
      SetOptions(merge: true),
    );

    return 'Product received';
  }

  // cancel order
  Future<String> cancelOrder(String productID) async {
    // get current user
    String orderID = '';
    String orderStatus = '';
    String sellerEmail = '';

    currentTime = Timestamp.now();

    // get user email
    // get seller email and product id
    _orderReference = FirebaseFirestore.instance
        .collection('cart_orders')
        .doc(userEmail)
        .collection('cart')
        .doc(productID);
    _futureOrderData = _orderReference.get();
    await _futureOrderData.then((value) {
      sellerEmail = value['sellerEmail'];
      orderStatus = value['status'];
      orderID = value['orderID'];
    });

    if (orderStatus != 'Ordering') {
      return 'Order not in ordering status';
    }

    // delete order from seller sell_orders
    _orderReference = FirebaseFirestore.instance
        .collection('cart_orders')
        .doc(sellerEmail)
        .collection('sell_orders')
        .doc(orderID);
    await _orderReference.delete();

    // set state order from buyer cart
    await FirebaseFirestore.instance
        .collection('cart_orders')
        .doc(userEmail)
        .collection('cart')
        .doc(productID)
        .set(
      {
        'status': 'In cart',
        'time': currentTime,
      },
      SetOptions(merge: true),
    );

    return 'Order canceled';
  }

  // buyer confirm order rejection
  Future<String> buyerConfirmOrderRejection(String productID) async {
    // get product status
    String productStatus = '';

    _orderReference = FirebaseFirestore.instance
        .collection('cart_orders')
        .doc(userEmail)
        .collection('cart')
        .doc(productID);
    _futureOrderData = _orderReference.get();
    await _futureOrderData.then((value) {
      sellerEmail = value['sellerEmail'];
      productStatus = value['status'];
    });

    if (productStatus != 'Order rejected') {
      return 'Product not in order-rejected status';
    }

    // creat new orderID
    var orderID = DateTime.now().millisecondsSinceEpoch.toString();

    currentTime = Timestamp.now();
    // get buyer email and product id
    await FirebaseFirestore.instance
        .collection('cart_orders')
        .doc(userEmail)
        .collection('cart')
        .doc(productID)
        .set(
      {
        'status': 'In cart',
        'time': currentTime,
        'orderID': orderID,
      },
      SetOptions(merge: true),
    );

    return 'Order rejected';
  }
}
