import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SellerAcceptedTab extends StatefulWidget {
  const SellerAcceptedTab({super.key});

  @override
  State<SellerAcceptedTab> createState() => SellerAcceptedTabState();
}

class SellerAcceptedTabState extends State<SellerAcceptedTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('sellerId', isEqualTo: userId)
          .where('acceptedBySeller', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No accepted orders yet.'));
        }

        final orders = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final orderDoc = orders[index];
            final order = orderDoc.data() as Map<String, dynamic>;
            final orderTitle = orderDoc.id.substring(0, 6);
            final total = order['total'] ?? 0;
            final items = List<Map<String, dynamic>>.from(order['items'] ?? []);
            final deliveryFee = order['deliveryFee'] ?? 25;
            final subtotal = order['subtotal'] ?? 0;

            return GestureDetector(
              onTap: () => _showOrderDetails(
                context,
                orderDoc.id,
                items,
                subtotal,
                deliveryFee,
              ),
              child: Container(
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
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 40,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Order #$orderTitle',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      '₱${(total as num).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showOrderDetails(
    BuildContext context,
    String orderId,
    List<Map<String, dynamic>> items,
    double subtotal,
    double deliveryFee,
  ) {
    double total = subtotal + deliveryFee;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            shrinkWrap: true,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Text(
                'Order #${orderId.substring(0, 6)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 16),

              // Items list
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    title: Text(item['foodName'] ?? 'Unnamed'),
                    subtitle: Text('x${item['quantity'] ?? 1}'),
                    trailing: Text(
                      '₱${((item['price'] ?? 0) * (item['quantity'] ?? 1)).toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
              const Divider(),
              Row(
                children: [
                  const Text(
                    'Subtotal:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text('₱${subtotal.toStringAsFixed(2)}'),
                ],
              ),
              Row(
                children: [
                  const Text('Delivery Fee:'),
                  const Spacer(),
                  Text('₱${deliveryFee.toStringAsFixed(2)}'),
                ],
              ),
              const Divider(),
              Row(
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '₱${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Ready for Pick-up button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  try {
                    final orderRef = FirebaseFirestore.instance
                        .collection('orders')
                        .doc(orderId);
                    final orderSnapshot = await orderRef.get();

                    if (!orderSnapshot.exists) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Order not found.')),
                      );
                      return;
                    }

                    final courierId = orderSnapshot.data()?['courierId'];

                    if (courierId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No courier assigned to this order.'),
                        ),
                      );
                      return;
                    }

                    // Update order status
                    await orderRef.update({'status': 'Ready for Pick-up'});

                    // Send notification
                    await FirebaseFirestore.instance
                        .collection('notifications')
                        .doc(courierId)
                        .collection('items')
                        .add({
                          'title': 'Order Ready for Pick-up',
                          'message':
                              'Your assigned order ($orderId) is now ready for pick-up.',
                          'timestamp': FieldValue.serverTimestamp(),
                          'isRead': false,
                          'type': 'new_order',
                        });

                    // Close dialog/page
                    Navigator.pop(context);

                    // Confirmation message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Order marked as Ready for Pick-up'),
                      ),
                    );
                  } catch (e) {
                    print("Error updating order: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update order: $e')),
                    );
                  }
                },
                child: const Text(
                  'Ready for Pick-up',
                  style: TextStyle(
                    fontSize: 16,
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
