import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class ClaimItem extends StatelessWidget {
  final String donationId;
  final String foodName;
  final String donorName;
  final int quantity;
  final String sellerName;

  const ClaimItem({
    super.key,
    required this.donationId,
    required this.foodName,
    required this.donorName,
    required this.quantity,
    required this.sellerName,
  });

  Future<void> _claimDonation(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final randomCode = (100000 + Random().nextInt(900000)).toString();

      await FirebaseFirestore.instance
          .collection('donations')
          .doc(donationId)
          .update({
            'status': 'claimed',
            'recipientId': user.uid,
            'recipientName': user.displayName ?? 'Unknown Recipient',
            'claimCode': randomCode,
          });

      // Show confirmation dialog
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Donation Claimed!',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Here is your 6-digit claim code:'),
              const SizedBox(height: 12),
              Text(
                randomCode,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Claim at: $sellerName',
                style: const TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 12),
              const Text(
                'Please present this code when receiving your donation.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error claiming donation: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to the donation document live
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('donations')
          .doc(donationId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(); // show nothing until data loads
        }

        final data = snapshot.data!.data() as Map<String, dynamic>?;
        if (data == null) return const SizedBox();

        final status = (data['status'] ?? 'pending').toLowerCase();
        final isClaimed = status == 'claimed';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 5,
              ),
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
                      foodName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Claim at: $sellerName',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    Text('Quantity: $quantity'),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: isClaimed ? null : () => _claimDonation(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isClaimed ? Colors.grey : Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  isClaimed ? 'Claimed' : 'Claim',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
