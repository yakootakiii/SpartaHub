import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrdersTab extends StatefulWidget {
  const OrdersTab();

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

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('courierId', isNull: true) // Only show orders with no courier
          .where('acceptedBySeller', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No available orders.'));
        }

        final orders = snapshot.data!.docs;

        // Group orders by sellerId (from first item in each order)
        final Map<String, List<QueryDocumentSnapshot>> groupedOrders = {};
        for (var doc in orders) {
          final data = doc.data() as Map<String, dynamic>;
          final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
          if (items.isEmpty) continue;

          final sellerId = items.first['sellerId'] ?? 'unknown';
          if (!groupedOrders.containsKey(sellerId)) {
            groupedOrders[sellerId] = [];
          }
          groupedOrders[sellerId]!.add(doc);
        }

        final groupedList = groupedOrders.entries.toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: groupedList.length,
          itemBuilder: (context, index) {
            // final sellerId = groupedList[index].key;
            final sellerOrders = groupedList[index].value;

            // Use sellerName from first item of first order
            final sellerName =
                (sellerOrders.first.data()
                    as Map<String, dynamic>)['items'][0]['sellerName'] ??
                'Unknown Seller';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sellerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                ...sellerOrders.map((orderDoc) {
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
                    onTap: () {
                      _showOrderDetails(
                        orderDoc.id,
                        sellerName,
                        items,
                        subtotal,
                        deliveryFee,
                        orderData['buyerName'] ?? 'Unknown Buyer',
                        orderData['deliveryAddress'] ?? 'No address provided',
                      );
                    },
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
                }),
                const SizedBox(height: 16),
              ],
            );
          },
        );
      },
    );
  }

  void _showOrderDetails(
    String orderId,
    String sellerName,
    List<Map<String, dynamic>> items,
    double subtotal,
    double deliveryFee,
    String buyerName,
    String deliveryAddress,
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
              // 🔹 Title shows the order number instead of seller name
              Text(
                'Order #${orderId.substring(0, 6)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 16),
              Text('Buyer: $buyerName'),
              Text('Delivery Address: $deliveryAddress'),
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

              // Accept Order button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  final user = FirebaseAuth.instance.currentUser!;
                  final courierId = user.uid;
                  final courierName = user.displayName ?? 'Courier';

                  await FirebaseFirestore.instance
                      .collection('orders')
                      .doc(orderId)
                      .update({
                        'courierId': courierId,
                        'courierName': courierName,
                      });

                  Navigator.pop(context); // close sheet
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('You have accepted this delivery.'),
                    ),
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
        );
      },
    );
  }
}
