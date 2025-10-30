import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab>
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
          .where('acceptedBySeller', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No orders yet.'));
        }

        final orders = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final orderDoc = orders[index];
            final orderData = orderDoc.data() as Map<String, dynamic>;
            final orderTitle = orderDoc.id.substring(0, 6);

            final items = List<Map<String, dynamic>>.from(
              orderData['items'] ?? [],
            );
            final subtotal = items.fold<double>(
              0,
              (sum, item) =>
                  sum + ((item['price'] ?? 0) * (item['quantity'] ?? 1)),
            );
            final deliveryFee = orderData['deliveryFee'] ?? 25;
            final total = subtotal + deliveryFee;

            return GestureDetector(
              onTap: () => _showOrderDetails(
                orderDoc.id,
                orderData['buyerName'] ?? 'Unknown Buyer',
                orderData['deliveryAddress'] ?? 'No address provided',
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
                      Icons.receipt_long,
                      color: Color(0xFFCD0000),
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
                      '₱${total.toStringAsFixed(2)}',
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
    String orderId,
    String buyerName,
    String deliveryAddress,
    List<Map<String, dynamic>> items,
    double subtotal,
    double deliveryFee,
  ) {
    final total = subtotal + deliveryFee;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text('Buyer: $buyerName'),
            Text('Delivery Address: $deliveryAddress'),
            const SizedBox(height: 16),
            ...items.map(
              (item) => ListTile(
                title: Text(item['foodName'] ?? 'Unnamed'),
                subtitle: Text('x${item['quantity'] ?? 1}'),
                trailing: Text(
                  '₱${((item['price'] ?? 0) * (item['quantity'] ?? 1)).toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                final orderRef = FirebaseFirestore.instance
                    .collection('orders')
                    .doc(orderId);
                final orderSnapshot = await orderRef.get();
                final userId = orderSnapshot.data()?['buyerId'];
                final sellerName = orderSnapshot.data()?['sellerName'];
                final orderTitle = orderId.substring(0, 6);
                await FirebaseFirestore.instance
                    .collection('orders')
                    .doc(orderId)
                    .update({'status': 'Accepted', 'acceptedBySeller': true});

                await FirebaseFirestore.instance
                    .collection('notifications')
                    .doc(userId)
                    .collection('items')
                    .add({
                      'title': 'Order Accepted',
                      'message':
                          '$sellerName has accepted your order $orderTitle.',
                      'timestamp': FieldValue.serverTimestamp(),
                      'isRead': false,
                      'type': 'new_order',
                    });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order marked as Accepted')),
                );
              },
              child: const Text(
                'Accept Order',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
