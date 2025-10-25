import 'package:flutter/material.dart';
import '../../../widgets/build_item.dart';

class Earnings extends StatelessWidget {
  const Earnings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Earnings'),
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
            status: 'Approved',
            total: '09*****8592',
            date: '',
            statusColor: Colors.green,
            items: ['Tertiary Payment Method'],
          ),
        ],
      ),
    );
  }
}
