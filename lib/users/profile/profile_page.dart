import 'package:flutter/material.dart';
import 'my_profile_page.dart';
import 'about_homeease.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white)),
        backgroundColor: const Color(0xFF673AB7),
        elevation: 4,
        shadowColor: Colors.deepPurple.withOpacity(0.2),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                _buildSectionHeader('Account Settings'),
                _buildListItem(
                  context,
                  title: 'My Profile',
                  icon: Icons.person_outline,
                  page: const MyProfilePage(),
                ),
                _buildListItem(
                  context,
                  title: 'Bookings',
                  icon: Icons.calendar_today_outlined,
                  page: Container(),
                ),
                _buildListItem(
                  context,
                  title: 'My Address',
                  icon: Icons.location_on_outlined,
                  page: Container(),
                ),
                const Divider(
                    height: 20, thickness: 8, color: Color(0xFFF5F5F5)),
                _buildSectionHeader('Support'),
                _buildListItem(
                  context,
                  title: 'About HomeEase',
                  icon: Icons.info_outline,
                  page: const AboutHomeEasePage(),
                ),
                _buildListItem(
                  context,
                  title: 'Contact Us',
                  icon: Icons.support_agent_outlined,
                  page: Container(),
                ),
                const Divider(
                    height: 20, thickness: 8, color: Color(0xFFF5F5F5)),
                _buildSectionHeader('Other'),
                _buildListItem(
                  context,
                  title: 'Register as Vendor',
                  icon: Icons.storefront_outlined,
                  page: Container(),
                ),
                _buildListItem(
                  context,
                  title: 'Share',
                  icon: Icons.share_outlined,
                  page: Container(),
                ),
                _buildActionTile(
                  title: 'Logout',
                  icon: Icons.logout_outlined,
                  color: Colors.red,
                  onTap: () => _showLogoutConfirmation(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildListItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget page,
  }) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFF673AB7).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF673AB7)),
      ),
      title: Text(title,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87)),
      trailing:
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      minLeadingWidth: 24,
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => page)),
    );
  }

  Widget _buildActionTile({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
      title: Text(title,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w500, color: color)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      minLeadingWidth: 24,
      onTap: onTap,
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Implement logout logic
              Navigator.pop(context);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
