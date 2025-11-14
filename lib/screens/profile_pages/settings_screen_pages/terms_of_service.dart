import 'package:flutter/material.dart';

class TermsOfService extends StatelessWidget {
  const TermsOfService({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Terms of Service'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Text(_termsText, style: TextStyle(fontSize: 15, height: 1.5)),
      ),
    );
  }
}

const String _termsText = """
TERMS OF SERVICE
Last Updated: Novermber 14, 2025

Welcome to our Food Delivery App. By using our services, you agree to follow the Terms of Service outlined below. These terms are written in accordance with general consumer practices and the Data Privacy Act of 2012 (Republic Act 10173) of the Philippines.

1. Acceptance of Terms
By using the App, you confirm that you are at least 18 years old and agree to comply with these Terms of Service.

2. Description of Service
The App provides a platform that connects customers, partner restaurants, and delivery riders. You can browse restaurants, place orders, track deliveries, and make payments.

3. User Accounts
You must create an account to access most features. You agree to:
• Provide accurate personal information
• Secure your password and login credentials
• Take responsibility for actions from your account

4. Ordering and Payments
When you place an order, you acknowledge that:
• Prices and availability may change without notice
• Additional fees may apply (delivery, service, platform fees)
• Payments made are final once the order is confirmed

5. Delivery and Fulfillment
Delivery times are estimates and may vary due to weather, traffic, location, or high volume.
You must ensure your delivery address is accurate. If the rider cannot reach you after reasonable attempts, your order may be canceled without refund.

6. Cancellations and Refunds
Cancellations may be allowed only before the restaurant accepts or starts preparing your order.
Refunds may be issued for:
• Wrong or missing items
• Failed delivery caused by rider or system error
Refund approval follows our internal evaluation process.

7. Restaurant Responsibilities
Partner restaurants are fully responsible for:
• Food preparation and quality
• Pricing and item descriptions
• Allergen and dietary information

8. User Conduct
You must NOT:
• Harass riders, restaurant staff, or support agents
• Submit fraudulent complaints or refund claims
• Use the app for illegal activities
• Exploit or disrupt app functionality

9. Intellectual Property
All branding, logos, and in-app content belong to the Company and may not be copied or redistributed without permission.

10. Third-Party Services
We use third-party services such as restaurants, payment processors, and mapping providers. We are not responsible for delays or errors arising from these partners.

11. Limitation of Liability
We are not liable for:
• Delivery delays due to external factors
• Food quality issues caused by restaurants
• Damages arising from misuse of the App
• Technical issues, downtimes, or service interruptions

12. Amendments to Terms
These Terms may be updated periodically. Continued use of the App means you accept the revised Terms of Service.

13. Contact Us
For questions, concerns, or reports, you may reach us through the in-app Help Center or our official website.

Thank you for using our service!
""";
