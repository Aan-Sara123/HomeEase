// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'firestore_service.dart';
import '../home_page/services_page.dart';
import 'vendor_registration.dart';

class VendorLoginPage extends StatefulWidget {
  const VendorLoginPage({super.key});

  @override
  VendorLoginPageState createState() => VendorLoginPageState();
}

class VendorLoginPageState extends State<VendorLoginPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  String _selectedCountryCode = '+1';
  final List<String> _countryCodes = ['+1', '+44', '+91', '+61', '+81', '+86'];

  void _loginVendor() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      _showSnackBar('Please enter both name and phone number');
      return;
    }

    try {
      final vendor = await _firestoreService.getVendorByNameAndPhone(name, "$_selectedCountryCode$phone");

      if (!mounted) return;

      if (vendor != null) {
        _showSnackBar('Welcome back, ${vendor["name"]}!');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ServicesPage()),
        );
      } else {
        _showSnackBar('Vendor not found! Please register first.');
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF673AB7), // Deep Purple
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vendor Login', 
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            color: Colors.white,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: const Color(0xFF673AB7), // Deep Purple
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF673AB7), Colors.white], // Deep Purple to white
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              elevation: 10,
              shadowColor: const Color(0xFF9C27B0).withOpacity(0.5), // Purple shadow
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: const Color(0xFFD1C4E9).withOpacity(0.5), width: 1), // Light purple border
              ),
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _WelcomeHeader(),
                    const SizedBox(height: 30),
                    _buildNameField(),
                    const SizedBox(height: 20),
                    _buildPhoneField(),
                    const SizedBox(height: 30),
                    _buildLoginButton(),
                    const SizedBox(height: 20),
                    _buildRegisterButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Name',
        labelStyle: const TextStyle(color: Color(0xFF673AB7)), // Deep Purple
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD1C4E9)), // Light purple
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD1C4E9)), // Light purple
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF9C27B0), width: 2), // Purple
        ),
        prefixIcon: const Icon(Icons.person, color: Color(0xFF673AB7)), // Deep Purple
        filled: true,
        fillColor: Colors.white,
      ),
      style: const TextStyle(color: Color(0xFF424242)), // Dark grey
    );
  }

  Widget _buildPhoneField() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFD1C4E9)), // Light purple
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: DropdownButton<String>(
            value: _selectedCountryCode,
            onChanged: (String? newValue) {
              setState(() => _selectedCountryCode = newValue!);
            },
            items: _countryCodes.map<DropdownMenuItem<String>>(
              (String value) => DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: const TextStyle(color: Color(0xFF673AB7)), // Deep Purple
                ),
              ),
            ).toList(),
            underline: Container(),
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF673AB7)), // Deep Purple
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              labelStyle: const TextStyle(color: Color(0xFF673AB7)), // Deep Purple
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFD1C4E9)), // Light purple
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFD1C4E9)), // Light purple
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF9C27B0), width: 2), // Purple
              ),
              prefixIcon: const Icon(Icons.phone, color: Color(0xFF673AB7)), // Deep Purple
              filled: true,
              fillColor: Colors.white,
            ),
            keyboardType: TextInputType.phone,
            style: const TextStyle(color: Color(0xFF424242)), // Dark grey
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _loginVendor,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        backgroundColor: const Color(0xFF673AB7), // Deep Purple
        elevation: 5,
        shadowColor: const Color(0xFF9C27B0).withOpacity(0.5), // Purple shadow
      ),
      child: const Text(
        'Login', 
        style: TextStyle(
          fontSize: 18, 
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const VendorRegistration()),
          );
        },
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF9C27B0), // Purple
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        child: const Text(
          'New Vendor? Create Account',
          style: TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.bold, 
            color: Color(0xFF9C27B0), // Purple
          ),
        ),
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Center(
          child: Icon(
            Icons.storefront,
            size: 60,
            color: Color(0xFF673AB7), // Deep Purple
          ),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'Welcome Back, Vendor',
            style: TextStyle(
              fontSize: 26, 
              fontWeight: FontWeight.bold, 
              color: Color(0xFF673AB7), // Deep Purple
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFEDE7F6), // Very light purple
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD1C4E9)), // Light purple
          ),
          child: const Text(
            '"Your service makes a difference."',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14, 
              fontStyle: FontStyle.italic,
              color: Color(0xFF9C27B0), // Purple
            ),
          ),
        ),
      ],
    );
  }
}