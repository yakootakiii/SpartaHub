import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'cart_item.dart';
import '../../services/order_service.dart';

class CartTab extends StatefulWidget {
  const CartTab({super.key});

  @override
  State<CartTab> createState() => _CartTabState();
}

class _CartTabState extends State<CartTab> {
  final user = FirebaseAuth.instance.currentUser;
  final Map<String, bool> _selectedItems = {}; // Track selected items

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Center(child: Text("Please log in to view your cart."));
    }

    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user!.uid)
                .collection('cart')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("Your cart is empty."));
              }

              final docs = snapshot.data!.docs;

              // Ensure map contains all items
              for (var doc in docs) {
                _selectedItems.putIfAbsent(doc.id, () => false);
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final isSelected = _selectedItems[doc.id] ?? false;

                  return CartItem(
                    name: data['foodName'] ?? 'Unnamed',
                    store: data['sellerName'] ?? 'Unknown Store',
                    price: (data['price'] ?? 0).toDouble(),
                    quantity: (data['quantity'] ?? 1) as int,
                    docId: doc.id,
                    isSelected: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        _selectedItems[doc.id] = value ?? false;
                      });
                    },
                  );
                },
              );
            },
          ),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .collection('cart')
              .snapshots(),
          builder: (context, snapshot) {
            double total = 0;

            if (snapshot.hasData) {
              for (var doc in snapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                final selected = _selectedItems[doc.id] ?? false;
                if (selected) {
                  total += (data['price'] ?? 0) * (data['quantity'] ?? 1);
                }
              }
            }

            return Container(
              padding: const EdgeInsets.all(16),
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
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Delivery: ₱25.00',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: total > 0
                                ? () {
                                    // Pass only selected items to checkout
                                    final selectedDocs = _selectedItems.entries
                                        .where((entry) => entry.value)
                                        .map((entry) => entry.key)
                                        .toList();

                                    if (selectedDocs.isEmpty) return;

                                    OrderService.showCheckoutDialog(
                                      context,
                                      selectedDocs,
                                    );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFCD0000),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Checkout',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: total > 0
                                ? () {
                                    // Pass only selected items to checkout
                                    final selectedDocs = _selectedItems.entries
                                        .where((entry) => entry.value)
                                        .map((entry) => entry.key)
                                        .toList();

                                    if (selectedDocs.isEmpty) return;

                                    OrderService.showCheckoutDialog(
                                      context,
                                      selectedDocs,
                                    );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Donate',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
