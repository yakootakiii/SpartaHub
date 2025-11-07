import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderService {
  static void showCheckoutDialog(
    BuildContext context, {
    List<String>? selectedDocIds,
    Map<String, dynamic>? directOrderItem,
  }) {
    const double deliveryFee = 25.0;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please log in first!')));
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('cart')
              .get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            // Filter selected items
            final allDocs = snapshot.data!.docs;
            List<QueryDocumentSnapshot> cartDocs;

            final items = <Map<String, dynamic>>[];
            double subtotal = 0;

            if (directOrderItem != null) {
              cartDocs = [];
            } else if (selectedDocIds != null && selectedDocIds.isNotEmpty) {
              cartDocs = allDocs
                  .where((doc) => selectedDocIds.contains(doc.id))
                  .toList();
            } else {
              cartDocs = allDocs;
            }

            // Calculate subtotal
            if (directOrderItem != null) {
              items.add(directOrderItem);
              subtotal =
                  (directOrderItem['price'] ?? 0) *
                  (directOrderItem['quantity'] ?? 1);
            } else {
              for (var doc in cartDocs) {
                final data = doc.data() as Map<String, dynamic>;
                items.add({
                  'foodName': data['foodName'] ?? 'Unnamed item',
                  'quantity': data['quantity'] ?? 1,
                  'price': data['price'] ?? 0,
                  'sellerId': data['sellerId'],
                  'sellerName': data['storeName'],
                });
                subtotal += (data['price'] ?? 0) * (data['quantity'] ?? 1);
              }
            }

            final total = subtotal + deliveryFee;

            // Address controller and variable
            final TextEditingController addressController =
                TextEditingController(text: 'BSU Main Campus, Batangas City');
            String deliveryAddress = addressController.text;

            return StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Checkout',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Delivery Address'),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                deliveryAddress,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                final newAddress = await showDialog<String>(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      backgroundColor: Colors.white,
                                      title: const Text(
                                        'Change Delivery Address',
                                      ),
                                      content: TextField(
                                        controller: addressController,
                                        decoration: const InputDecoration(
                                          hintText:
                                              'Enter new delivery address',
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text(
                                            'Cancel',
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(
                                              context,
                                              addressController.text.trim(),
                                            );
                                          },
                                          style: ButtonStyle(),
                                          child: const Text('Save'),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (newAddress != null &&
                                    newAddress.isNotEmpty) {
                                  setState(() {
                                    deliveryAddress = newAddress;
                                  });
                                }
                              },
                              child: const Text(
                                'Change',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Payment Method'),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.payment),
                            const SizedBox(width: 8),
                            const Expanded(child: Text('Cash on Delivery')),
                            TextButton(
                              onPressed: () {},
                              child: const Text(
                                'Change',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Text('Subtotal'),
                                const Spacer(),
                                Text('₱${subtotal.toStringAsFixed(2)}'),
                              ],
                            ),
                            Row(
                              children: [
                                const Text('Delivery Fee'),
                                const Spacer(),
                                Text('₱${deliveryFee.toStringAsFixed(2)}'),
                              ],
                            ),
                            const Divider(),
                            Row(
                              children: [
                                const Text(
                                  'Total',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                Text(
                                  '₱${total.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            final userId = user.uid;

                            // Only fetch selected items for checkout
                            final items = <Map<String, dynamic>>[];
                            double subtotal = 0;

                            for (var doc in cartDocs) {
                              final data = doc.data() as Map<String, dynamic>;
                              items.add({
                                'foodName': data['foodName'] ?? 'Unnamed item',
                                'quantity': data['quantity'] ?? 1,
                                'price': data['price'] ?? 0,
                                'sellerId': data['sellerId'],
                                'sellerName': data['storeName'],
                              });

                              subtotal +=
                                  (data['price'] ?? 0) *
                                  (data['quantity'] ?? 1);
                            }

                            // Fetch buyer name
                            final userDoc = await FirebaseFirestore.instance
                                .collection('users')
                                .doc(userId)
                                .get();
                            final buyerName =
                                userDoc.data()?['fullName'] ?? 'Unnamed User';

                            // Create order in Firestore
                            final orderRef = FirebaseFirestore.instance
                                .collection('orders')
                                .doc();

                            // Determine if it's a direct order or from cart
                            final isDirectOrder = directOrderItem != null;

                            await orderRef.set({
                              'buyerId': userId,
                              'buyerName': buyerName,
                              'sellerId': isDirectOrder
                                  ? directOrderItem['sellerId']
                                  : items.first['sellerId'],
                              'sellerName': isDirectOrder
                                  ? directOrderItem['sellerName']
                                  : items.first['sellerName'],
                              'courierId': null,
                              'courierName': null,
                              'acceptedBySeller': false,
                              'status': 'Processing',
                              'createdAt': FieldValue.serverTimestamp(),
                              'items': isDirectOrder
                                  ? [directOrderItem]
                                  : items,
                              'subtotal': isDirectOrder
                                  ? (directOrderItem['price'] ?? 0) *
                                        (directOrderItem['quantity'] ?? 1)
                                  : subtotal,
                              'deliveryFee': deliveryFee,
                              'total': isDirectOrder
                                  ? ((directOrderItem['price'] ?? 0) *
                                            (directOrderItem['quantity'] ??
                                                1)) +
                                        deliveryFee
                                  : subtotal + deliveryFee,
                              'deliveryAddress': deliveryAddress,
                              'courierConfirmation': false,
                              'userConfirmation': false,
                            }, SetOptions(merge: true));

                            final sellerId = isDirectOrder
                                ? directOrderItem['sellerId']
                                : items.first['sellerId'];

                            await FirebaseFirestore.instance
                                .collection('notifications')
                                .doc(sellerId)
                                .collection('items')
                                .add({
                                  'title': 'New Order Received',
                                  'message':
                                      'You have a new order from $buyerName',
                                  'timestamp': FieldValue.serverTimestamp(),
                                  'isRead': false,
                                  'type': 'new_order',
                                });

                            // Clear selected items from cart
                            WriteBatch batch = FirebaseFirestore.instance
                                .batch();
                            for (var doc in cartDocs) {
                              batch.delete(doc.reference);
                            }
                            await batch.commit();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Order placed successfully!'),
                              ),
                            );

                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFCD0000),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
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
      },
    );
  }
}
