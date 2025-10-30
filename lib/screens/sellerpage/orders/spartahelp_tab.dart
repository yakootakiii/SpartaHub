import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SpartaHelpTab extends StatefulWidget {
  const SpartaHelpTab({super.key});

  @override
  State<SpartaHelpTab> createState() => _SpartaHelpTabState();
}

class _SpartaHelpTabState extends State<SpartaHelpTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  Widget build(BuildContext context) {
    super.build(context);
    final String? sellerId = FirebaseAuth.instance.currentUser?.uid;

    if (sellerId == null) {
      return const Center(child: Text('Please log in as a seller.'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('donations')
          .where('sellerId', isEqualTo: sellerId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No donations found.'));
        }

        // 👇 Filter out redeemed items
        final donations = snapshot.data!.docs
            .where(
              (doc) =>
                  (doc['status'] ?? '').toString().toLowerCase() != 'redeemed',
            )
            .toList();

        if (donations.isEmpty) {
          return const Center(child: Text('No active donations.'));
        }

        return Container(
          color: Colors.grey[50], // optional background
          child: ListView.builder(
            itemCount: donations.length,
            itemBuilder: (context, index) {
              final donation = donations[index];
              final data = donation.data() as Map<String, dynamic>;

              return Card(
                color: Colors.white,
                elevation: 3,
                shadowColor: Colors.black26,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    data['foodName'] ?? 'Unknown item',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quantity: ${data['quantity']}',
                        style: const TextStyle(color: Colors.black87),
                      ),
                      Text(
                        'Status: ${data['status']}',
                        style: const TextStyle(color: Colors.black87),
                      ),
                      Text(
                        'Recipient: ${data['recipientName'] ?? 'N/A'}',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.black54,
                  ),
                  onTap: () => _showClaimDialog(context, donation.id, data),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showClaimDialog(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) {
    final List<TextEditingController> controllers = List.generate(
      6,
      (index) => TextEditingController(),
    );
    final focusNodes = List.generate(6, (index) => FocusNode());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Enter your 6-digit verification code'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 45,
                    child: TextField(
                      controller: controllers[index],
                      focusNode: focusNodes[index],
                      maxLength: 1,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          FocusScope.of(
                            context,
                          ).requestFocus(focusNodes[index + 1]);
                        } else if (value.isEmpty && index > 0) {
                          FocusScope.of(
                            context,
                          ).requestFocus(focusNodes[index - 1]);
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final enteredCode = controllers.map((c) => c.text).join('');
                  final claimCode = data['claimCode'];

                  if (enteredCode == claimCode) {
                    await FirebaseFirestore.instance
                        .collection('donations')
                        .doc(docId)
                        .update({'status': 'redeemed'});

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Item successfully redeemed!'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invalid claim code.')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFCD0000),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Claim',
                  style: TextStyle(
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
