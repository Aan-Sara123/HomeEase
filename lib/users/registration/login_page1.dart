// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../authentication/firestore_service.dart';
import '../services_page.dart';
import 'user_registration.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  
  String _selectedCountryCode = '+1';
  final List<String> _countryCodes = ['+1', '+44', '+91', '+61', '+81', '+86'];

  void _loginUser() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      if (!mounted) return;
      _showSnackBar('Please enter both name and phone number');
      return;
    }

    try {
      final user = await _firestoreService.getUserByNameAndPhone(name, "$_selectedCountryCode$phone");

      if (!mounted) return;

      if (user != null) {
        _showSnackBar('Welcome back, ${user["name"]}!');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ServicesPage()),
        );
      } else {
        _showSnackBar('User not found! Please register first.');
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Error: ${e.toString()}');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF6A1B9A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define color palette
    const Color primaryPurple = Color(0xFF6A1B9A);
    const Color darkPurple = Color(0xFF4A148C);
    const Color accentPurple = Color(0xFFAB47BC);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: darkPurple,
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [darkPurple, Colors.white],
            stops: [0.3, 1.0],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              elevation: 10,
              shadowColor: primaryPurple.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: accentPurple, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _WelcomeHeader(primaryPurple: primaryPurple),
                    const SizedBox(height: 20),
                    _buildNameField(primaryPurple, accentPurple),
                    const SizedBox(height: 16),
                    _buildPhoneField(primaryPurple, accentPurple),
                    const SizedBox(height: 20),
                    _buildLoginButton(darkPurple, primaryPurple),
                    const SizedBox(height: 20),
                    _buildRegisterButton(primaryPurple),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameField(Color primaryPurple, Color accentPurple) {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Name',
        labelStyle: TextStyle(color: primaryPurple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primaryPurple),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primaryPurple, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: accentPurple.withOpacity(0.5)),
        ),
        prefixIcon: Icon(Icons.person, color: accentPurple),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildPhoneField(Color primaryPurple, Color accentPurple) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: accentPurple.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: DropdownButton<String>(
            value: _selectedCountryCode,
            underline: const SizedBox(),
            onChanged: (String? newValue) {
              setState(() => _selectedCountryCode = newValue!);
            },
            items: _countryCodes.map<DropdownMenuItem<String>>(
              (String value) => DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: TextStyle(color: primaryPurple)),
              ),
            ).toList(),
            icon: Icon(Icons.arrow_drop_down, color: primaryPurple),
            dropdownColor: Colors.white,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              labelStyle: TextStyle(color: primaryPurple),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: primaryPurple),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: primaryPurple, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: accentPurple.withOpacity(0.5)),
              ),
              prefixIcon: Icon(Icons.phone, color: accentPurple),
              filled: true,
              fillColor: Colors.white,
            ),
            keyboardType: TextInputType.phone,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(Color darkPurple, Color primaryPurple) {
    return ElevatedButton(
      onPressed: _loginUser,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: darkPurple,
        elevation: 5,
        shadowColor: primaryPurple.withOpacity(0.5),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.login, color: Colors.white),
          SizedBox(width: 8),
          Text('Login', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRegisterButton(Color primaryPurple) {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UserRegistration()),
          );
        },
        style: TextButton.styleFrom(
          foregroundColor: primaryPurple,
        ),
        child: Text(
          'New User? Create Account',
          style: TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.bold, 
            color: primaryPurple,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  final Color primaryPurple;
  
  const _WelcomeHeader({required this.primaryPurple});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(
            'Welcome Back to HomeEase',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryPurple),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: primaryPurple.withOpacity(0.3), width: 1),
            ),
          ),
          child: const Text(
            '"Home is where love resides, memories are created, and laughter never ends."',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }
}