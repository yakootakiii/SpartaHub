import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spartahubdev/screens/authentication_screen.dart';

import 'seller_profile_pages/products.dart';
import 'seller_profile_pages/orders.dart';
import 'seller_profile_pages/earnings.dart';
import 'seller_profile_pages/settings_screen.dart';
import 'seller_profile_pages/help_support_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<String> _getUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('sellers')
          .doc(user.uid)
          .get();

      if (snapshot.exists) {
        return snapshot.data()?['fullName'] ?? 'No Name';
      }
    }
    return 'Guest';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header (Row, no blue background)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.store, size: 40, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    FutureBuilder<String>(
                      future: _getUserName(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text(
                            'Loading...',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return const Text(
                            'Error',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }
                        return Text(
                          snapshot.data ?? 'Guest',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Stats Widgets
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('sellers')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final sellerDoc = snapshot.data!;
                    final pendingOrders =
                        (sellerDoc['activeOrders'] as List<dynamic>?)?.length ??
                        0;
                    final totalSales = sellerDoc['earnings'] ?? 0.0;

                    // Format totalSales with currency and commas
                    final totalSalesFormatted =
                        '₱ ${totalSales.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')}';

                    return Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            'Pending Orders',
                            pendingOrders.toString(),
                            Icons.pending_actions,
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInfoCard(
                            'Total Sales',
                            totalSalesFormatted,
                            Icons.attach_money,
                            Colors.green,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Seller Options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildProfileOption(
                      'My Products',
                      Icons.inventory_2_outlined,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Products(),
                        ),
                      ),
                    ),
                    _buildProfileOption(
                      'Orders',
                      Icons.shopping_bag_outlined,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Orders()),
                      ),
                    ),
                    _buildProfileOption(
                      'Earnings',
                      Icons.account_balance_wallet_outlined,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Earnings(),
                        ),
                      ),
                    ),
                    _buildProfileOption(
                      'Settings',
                      Icons.settings_outlined,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      ),
                    ),
                    _buildProfileOption(
                      'Help & Support',
                      Icons.help_outline,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HelpSupportScreen(),
                        ),
                      ),
                    ),
                    _buildProfileOption('About', Icons.info_outline, () {}),

                    const SizedBox(height: 20),

                    _buildProfileOption('Sign Out', Icons.logout, () async {
                      final prefs = await SharedPreferences.getInstance();

                      // Fully sign out the seller
                      await FirebaseAuth.instance.signOut();

                      // Clear local login flags
                      await prefs.setBool('isSeller', false);
                      await prefs.setBool('isLoggedIn', false);
                      await prefs.setBool('rememberMe', false);

                      // Navigate back to user authentication screen
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AuthenticationScreen(),
                        ),
                        (route) => false,
                      );
                    }, isDestructive: true),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildProfileOption(
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 5),
        ],
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : Colors.grey[700],
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
        onTap: onTap,
      ),
    );
  }
}
