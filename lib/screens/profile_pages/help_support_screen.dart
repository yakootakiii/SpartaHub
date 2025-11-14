import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Help & Support'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Actions
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFFCD0000),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Need Help?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'We\'re here to help you 24/7',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickHelpButton(
                          'Call Us',
                          Icons.phone,
                          Colors.white,
                          Color(0xFFCD0000),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // FAQ Section
            Text(
              'Frequently Asked Questions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            _buildFAQItem(
              'How do I track my order?',
              'You can track your order in real-time through the app. Go to "My Orders" and select your active order to see its current status and location.',
            ),
            _buildFAQItem(
              'What payment methods are accepted?',
              'We accept cash on delivery, GCash, PayMaya, and major credit/debit cards. You can change your preferred payment method in the checkout screen.',
            ),
            _buildFAQItem(
              'How does the "Buy a Meal for Someone" feature work?',
              'Simply select this option during checkout, and your extra meal will be added to our community fund. Students in need can request these meals through our partner organizations at BSU.',
            ),
            _buildFAQItem(
              'Can I schedule orders in advance?',
              'Yes! Use our Advance Ordering system to place orders ahead of time. Perfect for busy schedules - your order will be ready for pickup at your chosen time.',
            ),
            _buildFAQItem(
              'What areas do you deliver to?',
              'We currently serve Batangas State University main campus and nearby residential areas. Delivery radius is approximately 5km from the campus.',
            ),

            SizedBox(height: 24),

            // Contact Information
            Text(
              'Contact Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            _buildContactItem(
              'Customer Service',
              '+63 912 345 6789',
              Icons.phone,
              Colors.green,
            ),
            _buildContactItem(
              'Email Support',
              'support@spartahub.com',
              Icons.email,
              Colors.blue,
            ),
            _buildContactItem(
              'Emergency Hotline',
              '+63 998 765 4321',
              Icons.emergency,
              Colors.red,
            ),

            SizedBox(height: 24),

            // Report Issue Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  _showReportIssueDialog(context);
                },
                icon: Icon(Icons.report_problem_outlined),
                label: Text('Report an Issue'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.blue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickHelpButton(
    String title,
    IconData icon,
    Color backgroundColor,
    Color textColor,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textColor, size: 20),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 5),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: TextStyle(color: Colors.grey[600], height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    String title,
    String contact,
    IconData icon,
    Color color,
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
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                Text(
                  contact,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
        ],
      ),
    );
  }

  void _showReportIssueDialog(BuildContext context) {
    final TextEditingController issueController = TextEditingController();
    String selectedCategory = 'Order Issue';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Report an Issue'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Category:'),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items:
                          [
                            'Order Issue',
                            'Payment Problem',
                            'Delivery Issue',
                            'App Bug',
                            'Other',
                          ].map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value!;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    Text('Describe the issue:'),
                    SizedBox(height: 8),
                    TextField(
                      controller: issueController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Please provide details about the issue...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Issue reported successfully. We\'ll get back to you soon!',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: Text('Submit Report'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
