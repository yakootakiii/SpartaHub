import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Order History'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('buyerId', isEqualTo: userId)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Check if snapshot has an error (like missing index)
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error fetching orders:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          // Check if data exists
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final orderDoc = orders[index];
              final data = orderDoc.data() as Map<String, dynamic>;

              // Parsing items
              final rawItems = data['items'] ?? [];
              final List<String> itemNames = [];
              final List<Map<String, dynamic>> itemDetails = [];

              if (rawItems is List) {
                for (var it in rawItems) {
                  if (it is String) {
                    itemNames.add(it);
                  } else if (it is Map) {
                    final map = Map<String, dynamic>.from(it);
                    final name =
                        (map['foodName'] as String?) ??
                        (map['name'] as String?) ??
                        'Unnamed Item';
                    itemNames.add(name);
                    itemDetails.add(map);
                  } else {
                    itemNames.add(it.toString());
                  }
                }
              }

              final status = data['status'] ?? 'Processing';
              final statusColor = _getStatusColor(status);
              final total = (data['total'] ?? 0.0).toDouble();
              final timestamp = data['createdAt'] as Timestamp?;
              final dateStr = timestamp != null
                  ? _formatDate(timestamp.toDate())
                  : 'Unknown Date';

              return GestureDetector(
                onTap: () => _showOrderDetails(
                  context,
                  orderDoc.id,
                  status,
                  statusColor,
                  dateStr,
                  itemNames,
                  itemDetails,
                  data,
                ),
                child: _buildOrderItem(
                  orderDoc.id,
                  status,
                  '₱${total.toStringAsFixed(2)}',
                  dateStr,
                  statusColor,
                  itemNames,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderItem(
    String orderId,
    String status,
    String total,
    String date,
    Color statusColor,
    List<String> items,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Order #${orderId.substring(0, 6)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            items.join(', '),
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                total,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const Spacer(),
              Text(
                date,
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(
    BuildContext context,
    String orderId,
    String status,
    Color statusColor,
    String date,
    List<String> itemNames,
    List<Map<String, dynamic>> itemDetails,
    Map<String, dynamic> data,
  ) {
    Future<void> _checkAndProcessDeliveryConfirmation(String orderId) async {
      final orderRef = FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId);
      final orderSnap = await orderRef.get();

      if (!orderSnap.exists) return;

      final orderData = orderSnap.data()!;
      final userConfirmed = orderData['userConfirmation'] ?? false;
      final courierConfirmed = orderData['courierConfirmation'] ?? false;
      final courierId = orderData['courierId'];
      final deliveryFee = (orderData['deliveryFee'] ?? 0).toDouble();

      if (userConfirmed && courierConfirmed && courierId != null) {
        final courierRef = FirebaseFirestore.instance
            .collection('couriers')
            .doc(courierId);

        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final courierSnap = await transaction.get(courierRef);
          final currentEarnings = (courierSnap.data()?['earnings'] ?? 0)
              .toDouble();

          transaction.update(courierRef, {
            'earnings': currentEarnings + deliveryFee,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          transaction.update(orderRef, {'status': 'Delivered'});
        });

        debugPrint('Earnings processed successfully for courier $courierId');
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (_, controller) => Padding(
            padding: const EdgeInsets.all(16),
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .doc(orderId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final orderData =
                    snapshot.data!.data() as Map<String, dynamic>? ?? {};
                final currentStatus = orderData['status'] ?? status;
                final userConfirmed = orderData['userConfirmation'] ?? false;
                final courierConfirmed =
                    orderData['courierConfirmation'] ?? false;

                return ListView(
                  controller: controller,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Order Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            currentStatus,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildItemsList(itemNames, itemDetails),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Subtotal:'),
                        const Spacer(),
                        Text('₱${(data['subtotal'] ?? 0).toStringAsFixed(2)}'),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Delivery Fee:'),
                        const Spacer(),
                        Text(
                          '₱${(data['deliveryFee'] ?? 0).toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(
                          '₱${(data['total'] ?? 0).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Cancel button (Processing only)
                    if (currentStatus == 'Processing')
                      ElevatedButton(
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('orders')
                              .doc(orderId)
                              .update({'status': 'Cancelled'});
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Order cancelled.')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(40),
                        ),
                        child: const Text('Cancel Order'),
                      ),

                    // Order Received button
                    if (currentStatus == 'Delivered' && !userConfirmed)
                      ElevatedButton(
                        onPressed: () async {
                          final orderSnapshot = await FirebaseFirestore.instance
                              .collection('orders')
                              .doc(orderId)
                              .get();

                          final buyerId = orderSnapshot['buyerId'];
                          final courierId = orderSnapshot['courierId'];
                          final orderTitle = orderId.substring(0, 6);

                          await FirebaseFirestore.instance
                              .collection('orders')
                              .doc(orderId)
                              .update({'userConfirmation': true});

                          await FirebaseFirestore.instance
                              .collection('notifications')
                              .doc(buyerId)
                              .collection('items')
                              .add({
                                'title': 'Order Delivered',
                                'message':
                                    'Your order $orderTitle has been successfully delivered.',
                                'timestamp': FieldValue.serverTimestamp(),
                                'isRead': false,
                                'type': 'order_delivery_confirmation',
                              });

                          await FirebaseFirestore.instance
                              .collection('notifications')
                              .doc(courierId)
                              .collection('items')
                              .add({
                                'title': 'Delivery Confirmed',
                                'message':
                                    'Delivery confirmed! ₱25 has been added to your earnings for order $orderTitle.',
                                'timestamp': FieldValue.serverTimestamp(),
                                'isRead': false,
                                'type': 'courier_earnings',
                              });

                          // Check if courier also confirmed
                          if (courierConfirmed == true) {
                            await _checkAndProcessDeliveryConfirmation(orderId);
                          }

                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Delivery confirmed successfully.'),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(40),
                        ),
                        child: const Text('Order Received'),
                      ),

                    if (currentStatus == 'Delivered' && userConfirmed)
                      const Text(
                        'You have confirmed this delivery.',
                        style: TextStyle(color: Colors.grey),
                      ),

                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildItemsList(
    List<String> itemNames,
    List<Map<String, dynamic>> itemDetails,
  ) {
    if (itemDetails.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: itemDetails.map((m) {
          final name = m['foodName'] ?? m['name'] ?? 'Unnamed Item';
          final qty = (m['quantity'] is num)
              ? (m['quantity'] as num).toInt()
              : 1;
          final price = (m['price'] is num)
              ? (m['price'] as num).toDouble()
              : 0.0;
          final store = m['storeName'] ?? m['restaurant'] ?? '';
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '$name${store.isNotEmpty ? " — $store" : ""} (x$qty)',
                  ),
                ),
                Text('₱${(price * qty).toStringAsFixed(2)}'),
              ],
            ),
          );
        }).toList(),
      );
    } else {
      return Text(itemNames.join(', '));
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Processing':
        return Colors.orange;
      case 'On the way':
        return Colors.blue;
      case 'Delivered':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
