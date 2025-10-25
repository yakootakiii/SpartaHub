import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _locationServices = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildSettingsSection('Account', [
            _buildSettingsItem('Edit Profile', Icons.person_outline, () {}),
            _buildSettingsItem('Change Password', Icons.lock_outline, () {}),
            _buildSettingsItem(
              'Privacy Settings',
              Icons.privacy_tip_outlined,
              () {},
            ),
          ]),

          _buildSettingsSection('Notifications', [
            _buildSwitchItem(
              'Push Notifications',
              Icons.notifications_outlined,
              _pushNotifications,
              (value) {
                setState(() {
                  _pushNotifications = value;
                });
              },
            ),
            _buildSwitchItem(
              'Email Notifications',
              Icons.email_outlined,
              _emailNotifications,
              (value) {
                setState(() {
                  _emailNotifications = value;
                });
              },
            ),
          ]),

          _buildSettingsSection('App Preferences', [
            _buildSwitchItem(
              'Location Services',
              Icons.location_on_outlined,
              _locationServices,
              (value) {
                setState(() {
                  _locationServices = value;
                });
              },
            ),
            _buildSettingsItem('Language', Icons.language, () {}),
            _buildSettingsItem('App Theme', Icons.palette_outlined, () {}),
          ]),

          _buildSettingsSection('Support', [
            _buildSettingsItem(
              'Report a Problem',
              Icons.report_outlined,
              () {},
            ),
            _buildSettingsItem(
              'Terms of Service',
              Icons.description_outlined,
              () {},
            ),
            _buildSettingsItem('Privacy Policy', Icons.policy_outlined, () {}),
          ]),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
        ...children,
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSettingsItem(String title, IconData icon, VoidCallback onTap) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 5),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey[700]),
        title: Text(title),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchItem(
    String title,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 5),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey[700]),
        title: Text(title),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.blue,
        ),
      ),
    );
  }
}
