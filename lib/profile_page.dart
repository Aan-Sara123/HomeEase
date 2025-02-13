import 'package:flutter/material.dart';
import 'my_profile_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: const Color(0xFF673AB7)),
      body: ListView(
        children: [
          _buildListItem(context, 'My Profile', const MyProfilePage()),
          _buildListItem(context, 'Bookings', Container()),
          _buildListItem(context, 'My Address', Container()),
          _buildListItem(context, 'About HomeEase', Container()),
          _buildListItem(context, 'Contact Us', Container()),
          _buildListItem(context, 'Register as Vendor', Container()),
          _buildListItem(context, 'Share', Container()),
          _buildListItem(context, 'Logout', Container()),
        ],
      ),
    );
  }

  Widget _buildListItem(BuildContext context, String title, Widget page) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 18)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => page)),
    );
  }
}
