import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AcceptedOrdersTab extends StatefulWidget {
  const AcceptedOrdersTab();

  @override
  State<AcceptedOrdersTab> createState() => _AcceptedOrdersTabState();
}

class _AcceptedOrdersTabState extends State<AcceptedOrdersTab>
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
