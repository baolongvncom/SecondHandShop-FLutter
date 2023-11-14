import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_turtorial/pages/product_page/product_detail.dart';
import 'package:flutter/material.dart';

class AddItem extends StatefulWidget {
  const AddItem({super.key});

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  final CollectionReference _reference =
      FirebaseFirestore.instance.collection('product_list');

  late Stream<QuerySnapshot> _stream;

  final currentUser = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    String userEmail = currentUser?.email ?? '';

    _stream = _reference.snapshots();

    return Scaffold(
      backgroundColor: const Color(0xFFFFDAB9),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF4169E1),
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(50),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 50),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 30),
                  title: Text('Hello ${userEmail.split('@')[0]}',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: Colors.white)),
                  subtitle: const GreetingWidget(),
                  // make subtitle align to left
                  isThreeLine: true,
                  autofocus: true,
                  trailing: const CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('lib/images/user_image.png'),
                  ),
                ),
                const SizedBox(height: 20)
              ],
            ),
          ),
          Container(
            color: const Color(0xFF4169E1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              decoration: const BoxDecoration(
                  color: Color(0xFFFFDAB9),
                  borderRadius:
                      BorderRadius.only(topLeft: Radius.circular(200))),
              child: StreamBuilder<Object>(
                stream: _stream,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
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

                    return GridView.builder(
                        padding: const EdgeInsets.all(5),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.9,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          var thisProduct = products[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ProductDetail(
                                      thisProduct['productID'],
                                      thisProduct['sellerEmail'])));
                            },
                            child: itemDashboard(
                              products[index]['name'],
                              thisProduct['imageURL'],
                              const Color(0xFF4169E1),
                              products[index]['price'],
                            ),
                          );
                        });
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ),
          const SizedBox(height: 20)
        ],
      ),
    );
  }

  itemDashboard(String title, String imageURL, Color background, int price) =>
      Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            // muốn căn chỉnh theo chiều dọc thì dùng crossAxisAlignment
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.blue,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      imageURL,
                      fit: BoxFit.fill,
                      width: 120,
                      height: 200,
                      scale: double.maxFinite,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 5.0,
              ),
              Text(
                // products is out demo list
                title,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "\$${price.toString()}",
                style: const TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.normal,
                ),
              )
            ],
          ),
        ),
      );
}

class GreetingWidget extends StatelessWidget {
  const GreetingWidget({super.key});

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning !';
    } else if (hour < 18) {
      return 'Good Afternoon !';
    } else {
      return 'Good Evening !';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(_getGreeting(),
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ));
  }
}
