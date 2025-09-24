import 'package:flutter/material.dart';
import '../../widgets/build_item.dart';

class PaymentMethods extends StatelessWidget {
  const PaymentMethods({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Payment Methods'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          BuildItem(
            orderNumber: 'Gcash',
            status: 'Approved',
            total: '09*****8592',
            date: '',
            statusColor: Colors.green,
            items: ['Primary Payment Method'],
          ),
          BuildItem(
            orderNumber: 'GoTyme',
            status: 'Approved',
            total: '09*****8592',
            date: '',
            statusColor: Colors.green,
            items: ['Secondary Payment Method'],
          ),
          BuildItem(
            orderNumber: 'Maya',
            status: 'Pending',
            total: '09*****8592',
            date: '',
            statusColor: Color(0xFFCD0000),
            items: ['Tertiary Payment Method'],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFCD0000),
        onPressed: () {
          // Handle add payment
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
