import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderService {
  static void showCheckoutDialog(BuildContext context) {
    const double deliveryFee = 25.0;

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
                          'buyerName': buyerName,
                          'sellerId': items.first['sellerId'],
                          'sellerName': items.first['sellerName'],
                          'status': 'Processing',
                          'createdAt': FieldValue.serverTimestamp(),
                          'items': items,
                          'subtotal': subtotal,
                          'deliveryFee': 25.0,
                          'total': subtotal + 25.0,
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
