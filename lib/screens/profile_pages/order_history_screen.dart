import 'package:flutter/material.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Order History'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildOrderItem(
            'Order #SH001',
            'Delivered',
            '₱415.00',
            'Dec 15, 2024',
            Colors.green,
            ['Chicken Adobo', 'Beef Tapa', 'Notebook (5pcs)'],
          ),
          _buildOrderItem(
            'Order #SH002',
            'On the way',
            '₱235.00',
            'Dec 14, 2024',
            Colors.blue,
            ['Pancit Canton', 'Iced Coffee'],
          ),
          _buildOrderItem(
            'Order #SH003',
            'Cancelled',
            '₱180.00',
            'Dec 13, 2024',
            Colors.red,
            ['Burger Meal'],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(
    String orderNumber,
    String status,
    String total,
    String date,
    Color statusColor,
    List<String> items,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
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
                  orderNumber,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
          SizedBox(height: 8),
          Text(
            items.join(', '),
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Text(
                total,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              Spacer(),
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
}
