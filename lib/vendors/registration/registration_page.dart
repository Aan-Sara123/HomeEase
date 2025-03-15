// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'vendor_database.dart';
import '../home_page/services_page.dart';

class VendorRegistrationPage extends StatefulWidget {
  const VendorRegistrationPage({super.key});

  @override
  VendorRegistrationPageState createState() => VendorRegistrationPageState();
}

class VendorRegistrationPageState extends State<VendorRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final VendorDatabaseService _vendorDatabase = VendorDatabaseService();
  String? _selectedFile;
  String? _selectedExpertise;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final List<String> _expertiseOptions = [
    'Cleaning',
    'Electronic Repairs',
    'Plumbing',
    'Appliance Repairs'
  ];

  @override
  void initState() {
    super.initState();
    _listenForVendorStatus();
  }

  /// **Listens for vendor status changes in Firestore**
  void _listenForVendorStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('vendors')
        .doc(user.uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        String status = snapshot.data()?['status'] ?? 'pending';

        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (status == 'accepted') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ServicesPage()),
              );
            } else if (status == 'rejected') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Your registration was rejected by the admin.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          });
        }
      }
    });
  }

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = result.files.single.name;
      });
    }
  }

  Future<void> _registerVendor() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _vendorDatabase.registerVendor(
          _nameController.text.trim(),
          _addressController.text.trim(),
          _selectedExpertise!,
          int.parse(_experienceController.text.trim()),
          _phoneController.text.trim(),
          _emailController.text.trim(),
          _selectedFile,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Vendor registered successfully!"),
            backgroundColor: Colors.purple[800],
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define a rich color palette
    final primaryPurple = Colors.purple[700];
    final lightPurple = Colors.purple[200];
    final darkPurple = Colors.purple[900];
    final accentPurple = Colors.purple[400];
    final backgroundPurple = Colors.purple[50];
    
    // Create consistent text styles
    final headingStyle = TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: darkPurple,
    );
    
    final subheadingStyle = TextStyle(
      fontSize: 16,
      color: primaryPurple,
      fontWeight: FontWeight.w500,
    );

    // Input field decoration
    final inputDecoration = InputDecoration(
      labelStyle: TextStyle(color: primaryPurple),
      hintStyle: TextStyle(color: Colors.purple[300]),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: lightPurple!, width: 1.0),
        borderRadius: BorderRadius.circular(12.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryPurple!, width: 2.0),
        borderRadius: BorderRadius.circular(12.0),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 1.0),
        borderRadius: BorderRadius.circular(12.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 2.0),
        borderRadius: BorderRadius.circular(12.0),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    );

    return Scaffold(
      backgroundColor: backgroundPurple,
      appBar: AppBar(
        title: const Text('Vendor Registration', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: darkPurple,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [backgroundPurple!, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Decorative quote
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        '"Excellence in service begins with professional registration"',
                        style: TextStyle(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          color: darkPurple,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Form heading
                Text('Personal Information', style: headingStyle),
                const SizedBox(height: 16),
                
                // Name
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _nameController,
                    decoration: inputDecoration.copyWith(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person, color: primaryPurple),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your name' : null,
                  ),
                ),
                const SizedBox(height: 20),

                // Address
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _addressController,
                    decoration: inputDecoration.copyWith(
                      labelText: 'Business Address',
                      prefixIcon: Icon(Icons.home, color: primaryPurple),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your address' : null,
                  ),
                ),
                const SizedBox(height: 30),

                // Professional details heading
                Text('Professional Details', style: headingStyle),
                const SizedBox(height: 16),

                // Expertise Dropdown
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField<String>(
                    decoration: inputDecoration.copyWith(
                      labelText: 'Area of Expertise',
                      prefixIcon: Icon(Icons.work, color: primaryPurple),
                    ),
                    value: _selectedExpertise,
                    dropdownColor: Colors.white,
                    items: _expertiseOptions.map((option) {
                      return DropdownMenuItem(
                        value: option,
                        child: Text(option),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedExpertise = value;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Please select your expertise' : null,
                  ),
                ),
                const SizedBox(height: 20),

                // Experience
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _experienceController,
                    decoration: inputDecoration.copyWith(
                      labelText: 'Years of Experience',
                      prefixIcon: Icon(Icons.timeline, color: primaryPurple),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your experience' : null,
                  ),
                ),
                const SizedBox(height: 20),

                // Phone
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _phoneController,
                    decoration: inputDecoration.copyWith(
                      labelText: 'Contact Number',
                      prefixIcon: Icon(Icons.phone, color: primaryPurple),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your phone number' : null,
                  ),
                ),
                const SizedBox(height: 20),

                // Email
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _emailController,
                    decoration: inputDecoration.copyWith(
                      labelText: 'Email Address',
                      prefixIcon: Icon(Icons.email, color: primaryPurple),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your email' : null,
                  ),
                ),
                const SizedBox(height: 30),

                // Documentation heading
                Text('Certification', style: headingStyle),
                const SizedBox(height: 16),
                
                // File upload info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: lightPurple, width: 1.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upload your professional certification',
                        style: subheadingStyle,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please provide a valid certificate to verify your expertise',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Certificate Upload Button
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload Certificate', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                
                if (_selectedFile != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.purple[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.purple[700]),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Selected File: $_selectedFile',
                            style: TextStyle(color: darkPurple),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 40),

                // Register Button
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: [primaryPurple, darkPurple!],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: darkPurple.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _registerVendor,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Complete Registration',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,color: Colors.white,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}