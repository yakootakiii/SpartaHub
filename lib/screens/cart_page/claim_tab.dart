import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'claim_item.dart';

class ClaimTab extends StatelessWidget {
  const ClaimTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('donations')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No donations available.'));
        }

        // Filter out redeemed donations
        final donations = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final status = (data['status'] ?? '').toString().toLowerCase();
          return status != 'redeemed';
        }).toList();

        if (donations.isEmpty) {
          return const Center(child: Text('No active donations.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: donations.length + 1,
          itemBuilder: (context, index) {
            // Display header first
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'For Pick-up only',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              );
            }

            final donation =
                donations[index - 1].data() as Map<String, dynamic>;
            return ClaimItem(
              donationId: donations[index - 1].id,
              foodName: donation['foodName'] ?? 'Unknown Food',
              donorName: donation['donorName'] ?? 'Unknown Donor',
              quantity: donation['quantity'] ?? 0,
              sellerName: donation['sellerName'] ?? 'Unknown Seller',
            );
          },
        );
      },
    );
  }
}
