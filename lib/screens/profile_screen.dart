import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'profile_pages/order_history_screen.dart';
import 'profile_pages/settings_screen.dart';
import 'profile_pages/help_support_screen.dart';
import 'onboarding_screen.dart';
import 'profile_pages/delivery_addresses.dart';
import 'profile_pages/payment_methods.dart';
import 'profile_pages/notifications.dart';
import 'profile_pages/about_app.dart';

import 'sellerpage/seller_login.dart';
import 'delivererpage/deliverer_login.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<String> _getUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
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
              // Profile Header
              // Profile Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFCD0000).withValues(alpha: 0.8),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Color(0xFFCD0000),
                      ),
                    ),
                    const SizedBox(height: 16),

                    //  Show user's full name from Firestore
                    FutureBuilder<String>(
                      future: _getUserName(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text(
                            'Loading...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return const Text(
                            'Error',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }
                        return Text(
                          snapshot.data ?? 'Guest',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),

                    Text(
                      'BSU Student',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Dynamic Stats Row
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator(
                            color: Colors.white,
                          );
                        }

                        final userDoc = snapshot.data!;
                        final orders = userDoc['ordersCount'] ?? 0;
                        final saved =
                            (userDoc['saved'] as List<dynamic>?)?.length ?? 0;
                        final points = userDoc['points'] ?? 0;

                        // Format points with commas
                        final pointsFormatted = points
                            .toString()
                            .replaceAllMapped(
                              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                              (match) => '${match[1]},',
                            );

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatItem('Orders', orders.toString()),
                            _buildStatItem('Saved', saved.toString()),
                            _buildStatItem('Points', pointsFormatted),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Profile Options (unchanged)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildProfileOption(
                      'My Orders',
                      Icons.shopping_bag_outlined,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OrderHistoryScreen(),
                        ),
                      ),
                    ),
                    _buildProfileOption(
                      'Delivery Addresses',
                      Icons.location_on_outlined,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DeliveryAddresses(),
                        ),
                      ),
                    ),
                    _buildProfileOption(
                      'Payment Methods',
                      Icons.payment_outlined,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PaymentMethods(),
                        ),
                      ),
                    ),
                    _buildProfileOption(
                      'Become a Deliverer',
                      Icons.shopping_bag_outlined,
                      () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const DeliverAuthenticationScreen(),
                        ),
                      ),
                    ),
                    _buildProfileOption(
                      'Notifications',
                      Icons.notifications_outlined,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Notifications(),
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
                    _buildProfileOption(
                      'About',
                      Icons.info_outline,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutApp(),
                        ),
                      ),
                    ),
                    _buildProfileOption(
                      'Login as Restaurant',
                      Icons.shopping_bag_outlined,
                      () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AuthenticationScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildProfileOption('Sign Out', Icons.logout, () {
                      _showSignOutDialog(context);
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

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 14,
          ),
        ),
      ],
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

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OnboardingScreen(),
                  ),
                  (route) => false,
                );
              },
              child: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
