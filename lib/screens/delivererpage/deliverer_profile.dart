import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'deliverer_profile_pages/orders.dart';
import 'deliverer_profile_pages/earnings.dart';
import 'deliverer_profile_pages/settings_screen.dart';
import 'deliverer_profile_pages/help_support_screen.dart';

import '../onboarding_screen.dart';

class CourierProfileScreen extends StatelessWidget {
  const CourierProfileScreen({super.key});

  // Fetch deliverer's name from Firestore
  Future<String> _getDelivererName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'Guest';

    final doc = await FirebaseFirestore.instance
        .collection('deliverers')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      final data = doc.data();
      return data?['fullName'] ?? 'No Name';
    }

    return 'Guest';
  }

  // Handle logout
  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile header
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
                      child: Icon(
                        Icons.delivery_dining,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    FutureBuilder<String>(
                      future: _getDelivererName(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text(
                            'Loading...',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return const Text(
                            'Error loading name',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          );
                        }

                        return Text(
                          snapshot.data ?? 'Guest',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Profile Options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildProfileOption(
                      'My Deliveries',
                      Icons.local_shipping_outlined,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const Orders()),
                      ),
                    ),
                    _buildProfileOption(
                      'Earnings',
                      Icons.account_balance_wallet_outlined,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const Earnings()),
                      ),
                    ),
                    _buildProfileOption(
                      'Settings',
                      Icons.settings_outlined,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      ),
                    ),
                    _buildProfileOption(
                      'Help & Support',
                      Icons.help_outline,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HelpSupportScreen(),
                        ),
                      ),
                    ),
                    _buildProfileOption('About', Icons.info_outline, () {}),

                    const SizedBox(height: 20),

                    _buildProfileOption(
                      'Sign Out',
                      Icons.logout,
                      () => _signOut(context),
                      isDestructive: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget builder for each option
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
