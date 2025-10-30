import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../widgets/notifications.dart';

class CourierNotificationsScreen extends StatelessWidget {
  const CourierNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final courierId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Activity'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            onPressed: () async {
              // Mark all as read
              final snapshot = await FirebaseFirestore.instance
                  .collection('notifications')
                  .doc(courierId)
                  .collection('items')
                  .get();

              for (var doc in snapshot.docs) {
                doc.reference.update({'isRead': true});
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .doc(courierId)
            .collection('items')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No notifications yet.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final notifications = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final data =
                  notifications[index].data() as Map<String, dynamic>? ?? {};

              final title = data['title'] ?? 'No Title';
              final message = data['message'] ?? 'No Message';
              final isRead = data['isRead'] ?? false;
              final timestamp = data['timestamp'] as Timestamp?;
              final time = timestamp != null
                  ? _formatTime(timestamp.toDate())
                  : 'Unknown time';

              final type = data['type'] ?? 'general';

              return NotificationItem(
                title: title,
                message: message,
                type: type,
                time: time,
                isRead: isRead,
                style: _getTypeStyle(type),
              );
            },
          );
        },
      ),
    );
  }

  // Returns icon and color based on type
  MapEntry<IconData, Color> _getTypeStyle(String type) {
    switch (type) {
      case 'ready_for_pickup':
        return MapEntry(Icons.directions_walk, Colors.green);
      case 'promotion':
        return MapEntry(Icons.local_offer, Colors.orange);
      case 'earnings_update':
        return MapEntry(Icons.attach_money, Colors.blue);
      case 'courier_earnings':
        return MapEntry(Icons.attach_money, Colors.blue);
      default:
        return MapEntry(Icons.notifications, Colors.grey);
    }
  }

  // Format timestamp to relative time string
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays} days ago';
  }
}
