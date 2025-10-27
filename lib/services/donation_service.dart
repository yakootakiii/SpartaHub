import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DonationService {
  static void showDonationDialog(
    BuildContext context, [
    List<String>? selectedDocIds,
  ]) {
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
            final cartDocs =
                (selectedDocIds != null && selectedDocIds.isNotEmpty)
                ? allDocs
                      .where((doc) => selectedDocIds.contains(doc.id))
                      .toList()
                : allDocs;

            if (cartDocs.isEmpty) {
              return const Center(
                child: Text("No items selected for donation."),
              );
            }

            return Container(
              padding: const EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Donate Food',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Food List Preview
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartDocs.length,
                      itemBuilder: (context, index) {
                        final data =
                            cartDocs[index].data() as Map<String, dynamic>;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(data['foodName'] ?? 'Unnamed item'),
                          subtitle: Text('Quantity: ${data['quantity'] ?? 1}'),
                        );
                      },
                    ),
                  ),

                  const Divider(),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        final donorId = user.uid;

                        // Fetch donor name
                        final userDoc = await FirebaseFirestore.instance
                            .collection('users')
                            .doc(donorId)
                            .get();
                        final donorName =
                            userDoc.data()?['fullName'] ?? 'Anonymous Donor';

                        // Add each selected item as a separate donation
                        WriteBatch batch = FirebaseFirestore.instance.batch();

                        for (var doc in cartDocs) {
                          final data = doc.data() as Map<String, dynamic>;
                          final donationRef = FirebaseFirestore.instance
                              .collection('donations')
                              .doc();

                          batch.set(donationRef, {
                            'donorId': donorId,
                            'donorName': donorName,
                            'foodName': data['foodName'] ?? 'Unnamed item',
                            'quantity': data['quantity'] ?? 1,
                            'sellerId': data['sellerId'] ?? '',
                            'sellerName': data['storeName'] ?? '',
                            'recipientId': null,
                            'recipientName': null,
                            'status': 'Pending',
                            'claimCode': null,
                            'createdAt': FieldValue.serverTimestamp(),
                          });
                        }

                        // Remove donated items from cart
                        for (var doc in cartDocs) {
                          batch.delete(doc.reference);
                        }

                        await batch.commit();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Donation submitted successfully!'),
                          ),
                        );

                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Confirm Donation',
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

  /// Generates a 6-digit random claim code
  static String generateClaimCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  /// Updates a donation to "Claimed" and assigns recipient + claim code
  static Future<void> claimDonation(
    String donationId,
    String recipientId,
    String recipientName,
  ) async {
    final claimCode = generateClaimCode();

    await FirebaseFirestore.instance
        .collection('donations')
        .doc(donationId)
        .update({
          'recipientId': recipientId,
          'recipientName': recipientName,
          'status': 'Claimed',
          'claimCode': claimCode,
        });
  }
}
