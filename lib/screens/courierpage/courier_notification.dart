import 'package:flutter/material.dart';

class CourierNotificationsScreen extends StatelessWidget {
  const CourierNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Activity',
          style: TextStyle(
            color: Color(0xFFCD0000),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: Icon(Icons.mark_email_read), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildNotificationItem(
            'New Promotion',
            'Get 20% off on your next grocery order. Limited time offer!',
            Icons.local_offer,
            Colors.orange,
            '1 hour ago',
          ),
          _buildNotificationItem(
            'Order Confirmed',
            'Your advance order for tomorrow has been confirmed by Filipino Kitchen.',
            Icons.restaurant,
            Colors.blue,
            '3 hours ago',
          ),
          _buildNotificationItem(
            'Someone Bought a Meal',
            'A kind soul bought a meal for students in need. Thank you for your generosity!',
            Icons.favorite,
            Colors.red,
            '1 day ago',
          ),
          _buildNotificationItem(
            'New Vendor Joined',
            'Sweet Treats is now available on SpartaHub. Check out their desserts!',
            Icons.store,
            Colors.purple,
            '2 days ago',
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    String title,
    String message,
    IconData icon,
    Color color,
    String time,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 5),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
