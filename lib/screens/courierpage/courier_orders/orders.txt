import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CourierOrderScreen extends StatefulWidget {
  const CourierOrderScreen({super.key});

  @override
  State<CourierOrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<CourierOrderScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // 2 tabs only
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Color(0xFFCD0000),
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: Color(0xFFCD0000),
          tabs: const [
            Tab(text: 'Available Orders'),
            Tab(text: 'Accepted Orders'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [_OrdersTab(), _AcceptedOrdersTab()],
      ),
    );
  }
}

class _OrdersTab extends StatefulWidget {
  const _OrdersTab();

  @override
  State<_OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<_OrdersTab>
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

class _AcceptedOrdersTab extends StatefulWidget {
  const _AcceptedOrdersTab();

  @override
  State<_AcceptedOrdersTab> createState() => _AcceptedOrdersTabState();
}

class _AcceptedOrdersTabState extends State<_AcceptedOrdersTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final courierId = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('courierId', isEqualTo: courierId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No accepted deliveries yet.'));
        }

        // Filter out orders already confirmed by both parties
        final orders = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final courierConfirmed = data['courierConfirmation'] ?? false;
          final userConfirmed = data['userConfirmation'] ?? false;
          return !(courierConfirmed && userConfirmed);
        }).toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final orderDoc = orders[index];
            final orderData = orderDoc.data() as Map<String, dynamic>;

            final orderTitle = orderDoc.id.substring(0, 6);
            final buyerName = orderData['buyerName'] ?? 'Unknown Buyer';
            final deliveryAddress =
                orderData['deliveryAddress'] ?? 'No address provided';
            final total = (orderData['total'] ?? 0).toDouble();
            final status = orderData['status'] ?? 'Processing';

            return GestureDetector(
              onTap: () => _showOrderDetails(
                orderId: orderDoc.id,
                buyerName: buyerName,
                deliveryAddress: deliveryAddress,
                total: total,
                status: status,
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
                      Icons.local_shipping,
                      color: Colors.green,
                      size: 40,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #$orderTitle',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            buyerName,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            status,
                            style: TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 13,
                            ),
                          ),
                        ],
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

  void _showOrderDetails({
    required String orderId,
    required String buyerName,
    required String deliveryAddress,
    required double total,
    required String status,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        String currentStatus = status;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16),
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
                  const SizedBox(height: 12),
                  Text('Buyer: $buyerName'),
                  Text('Delivery Address: $deliveryAddress'),
                  const Divider(height: 30),
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
                          color: Colors.green,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // live order doc stream to show status/confirmations
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('orders')
                        .doc(orderId)
                        .snapshots(),
                    builder: (context, snap) {
                      if (!snap.hasData) return const SizedBox.shrink();

                      final orderData =
                          snap.data!.data() as Map<String, dynamic>? ?? {};
                      final courierConfirmed =
                          orderData['courierConfirmation'] ?? false;
                      final userConfirmed =
                          orderData['userConfirmation'] ?? false;
                      final statusFromDb = orderData['status'] ?? currentStatus;

                      // keep the local label in sync with DB
                      currentStatus = statusFromDb;

                      // If courier confirmed but buyer hasn't -> show waiting message
                      if (courierConfirmed && !userConfirmed) {
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Waiting for $buyerName to Confirm Delivery',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      // If both confirmed, hide button entirely (or show done text)
                      if (courierConfirmed && userConfirmed) {
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          alignment: Alignment.center,
                          child: const Text(
                            'Delivery completed',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }

                      // Otherwise show the appropriate action button
                      String buttonText;
                      Color buttonColor;

                      if (currentStatus == 'Ready for Pick-up') {
                        buttonText = 'Picked Up';
                        buttonColor = Colors.orange;
                      } else if (currentStatus == 'Picked Up') {
                        buttonText = 'Mark as Delivered';
                        buttonColor = Colors.blue;
                      } else {
                        // fallback: hide
                        return const SizedBox.shrink();
                      }

                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          // Decide new status and perform a single update when delivering
                          if (currentStatus == 'Ready for Pick-up') {
                            final newStatus = 'Picked Up';
                            await FirebaseFirestore.instance
                                .collection('orders')
                                .doc(orderId)
                                .update({'status': newStatus});
                            setModalState(() {
                              currentStatus = newStatus;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Order marked as $newStatus'),
                              ),
                            );
                          } else if (currentStatus == 'Picked Up') {
                            final newStatus = 'Delivered';
                            // update status and courierConfirmation in one write
                            await FirebaseFirestore.instance
                                .collection('orders')
                                .doc(orderId)
                                .update({
                                  'status': newStatus,
                                  'courierConfirmation': true,
                                });

                            // process earnings if buyer already confirmed
                            await _checkAndProcessEarnings(orderId);

                            setModalState(() {
                              currentStatus = newStatus;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Order marked as $newStatus'),
                              ),
                            );

                            // keep sheet open to show waiting message; close only if you want:
                            // Navigator.pop(context);
                          }
                        },
                        child: Text(
                          buttonText,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _checkAndProcessEarnings(String orderId) async {
    final orderDoc = await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .get();

    final data = orderDoc.data()!;
    final courierConfirmed = data['courierConfirmation'] ?? false;
    final userConfirmed = data['userConfirmation'] ?? false;

    // Only process if both are confirmed
    if (courierConfirmed && userConfirmed) {
      final courierId = data['courierId'];
      const courierEarning = 25.0; // Example fixed delivery fee

      final courierRef = FirebaseFirestore.instance
          .collection('couriers')
          .doc(courierId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final courierSnap = await transaction.get(courierRef);
        if (!courierSnap.exists) return;

        final currentEarnings = (courierSnap.data()?['earnings'] ?? 0)
            .toDouble();
        transaction.update(courierRef, {
          'earnings': currentEarnings + courierEarning,
        });
      });
    }
  }
}
