import 'package:flutter/material.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -------------------------
            // PRIVACY POLICY
            // -------------------------
            const Text(
              'Privacy Policy',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            const Text(
              "Last Updated: November 14, 2025\n\n"
              "This Privacy Policy explains how Sparta Store collects, uses, and protects your personal information. "
              "By using this app, you agree to the practices described here, in compliance with the Data Privacy Act of 2012 (RA 10173).",
              style: TextStyle(fontSize: 15, height: 1.5),
            ),

            const SizedBox(height: 16),
            const Text(
              '1. Information We Collect',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),

            const Text(
              "• Name, email, phone number\n"
              "• Delivery address and location info\n"
              "• Order history and app activity\n"
              "• Payment info (processed via third-party gateways)\n"
              "• Device data (model, OS version, usage logs)\n",
              style: TextStyle(fontSize: 15),
            ),

            const SizedBox(height: 16),
            const Text(
              '2. How We Use Your Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),

            const Text(
              "• To process and deliver orders\n"
              "• To maintain your account and preferences\n"
              "• To improve app performance and features\n"
              "• To provide customer support\n"
              "• To prevent fraud and ensure platform safety\n",
              style: TextStyle(fontSize: 15),
            ),

            const SizedBox(height: 16),
            const Text(
              '3. Sharing of Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),

            const Text(
              "We may share your information with:\n"
              "• Partner restaurants or sellers\n"
              "• Delivery riders\n"
              "• Payment processors\n"
              "• Service providers involved in app operations\n\n"
              "We never sell your personal information to third parties.",
              style: TextStyle(fontSize: 15),
            ),

            const SizedBox(height: 16),
            const Text(
              '4. Your Rights (RA 10173 - Data Privacy Act)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),

            const Text(
              "• Right to access your data\n"
              "• Right to correct inaccurate data\n"
              "• Right to withdraw consent\n"
              "• Right to request deletion\n"
              "• Right to file a complaint with the National Privacy Commission (NPC)\n",
              style: TextStyle(fontSize: 15),
            ),

            const SizedBox(height: 16),
            const Text(
              '5. Data Protection',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),

            const Text(
              "We use security measures such as encryption, authentication, "
              "and access controls to safeguard your information. Only authorized personnel may access user data.",
              style: TextStyle(fontSize: 15),
            ),

            const SizedBox(height: 16),
            const Text(
              '6. Data Retention',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),

            const Text(
              "We retain your data only as long as necessary for service fulfillment, legal requirements, and security purposes.",
              style: TextStyle(fontSize: 15),
            ),

            const SizedBox(height: 16),
            const Text(
              '7. Contact Us',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),

            const Text(
              "If you have questions about your data or privacy rights, you may contact our Data Protection Officer via our in-app Help Center.",
              style: TextStyle(fontSize: 15),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
