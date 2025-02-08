import 'package:flutter/material.dart';
import 'firestore_service.dart';
import 'services_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  void _loginUser() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    // Check if inputs are empty
    if (name.isEmpty || phone.isEmpty) {
      if (!mounted) return; // Ensure State is mounted before using context
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both name and phone number')),
      );
      return;
    }

    try {
      // Attempt to get user from Firestore
      final user = await _firestoreService.getUserByNameAndPhone(name, phone);

      if (!mounted) return; // Check if State is still mounted

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Welcome back, ${user["name"]}!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ServicesPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found! Please register first.')),
        );
      }
    } catch (e) {
      if (!mounted) return; // Check if State is still mounted
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Login to HomeEase',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loginUser,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
              ),
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
