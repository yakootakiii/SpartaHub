import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'My Orders',
          style: TextStyle(
            color: Color(0xFFCD0000),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Color(0xFFCD0000),
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: Color(0xFFCD0000),
          tabs: [
            Tab(text: 'Cart'),
            Tab(text: 'Favorites'),
            Tab(text: 'Saved'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildCartTab(), _buildFavoritesTab(), _buildSavedTab()],
      ),
    );
  }

  Widget _buildCartTab() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(child: Text("Please log in to view your cart."));
    }

    return Column(
      children: [
        // 🔎 Listen to Firestore cart items
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('cart')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text("Your cart is empty."));
              }

              final docs = snapshot.data!.docs;

              // Compute total
              double total = docs.fold(0, (sum, doc) {
                final data = doc.data() as Map<String, dynamic>;
                return sum + (data['price'] ?? 0) * (data['quantity'] ?? 1);
              });

              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  return _buildCartItem(
                    data['foodName'] ?? 'Unnamed',
                    data['sellerName'] ?? 'Unknown Store',
                    (data['price'] ?? 0).toDouble(),
                    (data['quantity'] ?? 1) as int,
                    docs[index].id, // pass docId to update qty
                  );
                },
              );
            },
          ),
        ),

        // ✅ Bottom summary
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('cart')
              .snapshots(),
          builder: (context, snapshot) {
            double total = 0;
            if (snapshot.hasData) {
              total = snapshot.data!.docs.fold(0, (sum, doc) {
                final data = doc.data() as Map<String, dynamic>;
                return sum + (data['price'] ?? 0) * (data['quantity'] ?? 1);
              });
            }

            return Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Total: ₱${total.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      Text(
                        'Delivery: ₱25.00',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        _showCheckoutDialog();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFCD0000),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Proceed to Checkout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCartItem(
    String name,
    String store,
    double price,
    int quantity,
    String docId,
  ) {
    final user = FirebaseAuth.instance.currentUser;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 5),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.fastfood, color: Colors.grey[400]),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  store,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                Text(
                  '₱${price.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (quantity > 1) {
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(user!.uid)
                        .collection('cart')
                        .doc(docId)
                        .update({'quantity': quantity - 1});
                  } else {
                    // remove item if qty = 1
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(user!.uid)
                        .collection('cart')
                        .doc(docId)
                        .delete();
                  }
                },
                icon: Icon(Icons.remove_circle_outline),
                color: Colors.grey[600],
              ),
              Text(
                quantity.toString(),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () {
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(user!.uid)
                      .collection('cart')
                      .doc(docId)
                      .update({'quantity': quantity + 1});
                },
                icon: Icon(Icons.add_circle_outline),
                color: Color(0xFFCD0000),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesTab() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildFavoriteItem('Chicken Sisig', 'Grill Master', 120.0, 4.9),
        _buildFavoriteItem('Lumpia Shanghai', 'Home Cooked', 80.0, 4.7),
        _buildFavoriteItem('Buko Pie', 'Sweet Treats', 150.0, 4.8),
      ],
    );
  }

  Widget _buildFavoriteItem(
    String name,
    String store,
    double price,
    double rating,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 5),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.fastfood, color: Colors.grey[400]),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  store,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                Row(
                  children: [
                    Text(
                      '₱${price.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    Icon(Icons.star, size: 16, color: Colors.orange),
                    Text(' $rating'),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.favorite, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedTab() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildSavedItem('Weekly Grocery List', 'Saved for later ordering'),
        _buildSavedItem('School Supplies Bundle', 'For next semester'),
        _buildSavedItem('Birthday Party Package', 'Celebration essentials'),
      ],
    );
  }

  Widget _buildSavedItem(String title, String description) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 5),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFFCD0000).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.bookmark, color: Color(0xFFCD0000)),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
          IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
        ],
      ),
    );
  }

  void _showCheckoutDialog() {
    const double deliveryFee = 25.0; // constant delivery fee

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('cart')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final cartDocs = snapshot.data!.docs;

            // Calculate subtotal
            double subtotal = 0;
            for (var doc in cartDocs) {
              final data = doc.data() as Map<String, dynamic>;
              final price = (data['price'] ?? 0).toDouble();
              final quantity = (data['quantity'] ?? 1).toInt();
              subtotal += price * quantity;
            }

            final total = subtotal + deliveryFee;

            return Container(
              padding: EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Checkout',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text('Delivery Address'),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on),
                        SizedBox(width: 8),
                        Expanded(child: Text('BSU Main Campus, Batangas City')),
                        TextButton(onPressed: () {}, child: Text('Change')),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text('Payment Method'),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.payment),
                        SizedBox(width: 8),
                        Expanded(child: Text('Cash on Delivery')),
                        TextButton(onPressed: () {}, child: Text('Change')),
                      ],
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text('Subtotal'),
                            Spacer(),
                            Text('₱${subtotal.toStringAsFixed(2)}'),
                          ],
                        ),
                        Row(
                          children: [
                            Text('Delivery Fee'),
                            Spacer(),
                            Text('₱${deliveryFee.toStringAsFixed(2)}'),
                          ],
                        ),
                        Divider(),
                        Row(
                          children: [
                            Text(
                              'Total',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Spacer(),
                            Text(
                              '₱${total.toStringAsFixed(2)}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        final user = FirebaseAuth.instance.currentUser!;
                        final userId = user.uid;

                        final cartRef = FirebaseFirestore.instance
                            .collection('users')
                            .doc(userId)
                            .collection('cart');

                        final cartSnapshot = await cartRef.get();

                        if (cartSnapshot.docs.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Your cart is empty!'),
                            ),
                          );
                          return;
                        }

                        // 🔹 Fetch buyer name from Firestore profile
                        final userDoc = await FirebaseFirestore.instance
                            .collection('users')
                            .doc(userId)
                            .get();
                        final buyerName =
                            userDoc.data()?['fullName'] ?? 'Unnamed User';

                        // Collect items from cart
                        List<Map<String, dynamic>> items = [];
                        double subtotal = 0;

                        for (var doc in cartSnapshot.docs) {
                          final data = doc.data();
                          items.add({
                            'foodName': data['foodName'] ?? 'Unnamed item',
                            'quantity': data['quantity'] ?? 1,
                            'price': data['price'] ?? 0,
                            'sellerId': data['sellerId'],
                            'sellerName': data['storeName'],
                          });

                          subtotal +=
                              (data['price'] ?? 0) * (data['quantity'] ?? 1);
                        }

                        // Create an order in Firestore
                        final orderRef = FirebaseFirestore.instance
                            .collection('orders')
                            .doc();

                        await orderRef.set({
                          'buyerId': userId,
                          'buyerName':
                              buyerName, // ✅ now guaranteed to be correct
                          'sellerId': items.first['sellerId'],
                          'sellerName': items.first['sellerName'],
                          'status': 'Processing',
                          'createdAt': FieldValue.serverTimestamp(),
                          'items': items,
                          'subtotal': subtotal,
                          'deliveryFee': 25,
                          'total': subtotal + 25,
                          'deliveryAddress': 'CICS Building, Room 106',
                        });

                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(userId)
                            .update({'ordersCount': FieldValue.increment(1)});

                        // Clear cart
                        WriteBatch batch = FirebaseFirestore.instance.batch();
                        for (var doc in cartSnapshot.docs) {
                          batch.delete(doc.reference);
                        }
                        await batch.commit();

                        // Snackbar
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Order placed successfully!'),
                          ),
                        );

                        Navigator.pop(context);
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFCD0000),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Place Order',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
