import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartItem extends StatelessWidget {
  final String name, store, docId;
  final double price;
  final int quantity;

  const CartItem({
    super.key,
    required this.name,
    required this.store,
    required this.price,
    required this.quantity,
    required this.docId,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  store,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                Text(
                  '₱${price.toStringAsFixed(0)}',
                  style: const TextStyle(
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
                style: const TextStyle(fontWeight: FontWeight.bold),
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
                color: const Color(0xFFCD0000),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
