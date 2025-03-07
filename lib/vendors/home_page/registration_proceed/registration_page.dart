// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'vendor_database.dart';
import '../services_page.dart';

class VendorRegistrationPage extends StatefulWidget {
  const VendorRegistrationPage({super.key});

  @override
  VendorRegistrationPageState createState() => VendorRegistrationPageState();
}

class VendorRegistrationPageState extends State<VendorRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final VendorDatabaseService _vendorDatabase = VendorDatabaseService();
  String? _selectedFile;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _expertiseController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _listenForVendorStatus();
  }

  /// **Listens for vendor status changes in Firestore**
  void _listenForVendorStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // Ensure user is logged in

    FirebaseFirestore.instance.collection('vendors').doc(user.uid).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        String status = snapshot.data()?['status'] ?? 'pending';

        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;

            if (status == 'accepted') {
              // Navigate to ServicesPage if approved
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ServicesPage()),
              );
            } else if (status == 'rejected') {
              // Show a message if rejected
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
          _expertiseController.text.trim(),
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
    // Define purple color palette
    final primaryPurple = Colors.purple[700];
    final lightPurple = Colors.purple[200];
    final darkPurple = Colors.purple[900];
    final accentPurple = Colors.purpleAccent[100];
    
    // Custom input decoration theme
    final inputDecoration = InputDecoration(
      labelStyle: TextStyle(color: primaryPurple),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: lightPurple!, width: 1.0),
        borderRadius: BorderRadius.circular(10.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryPurple!, width: 2.0),
        borderRadius: BorderRadius.circular(10.0),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 1.0),
        borderRadius: BorderRadius.circular(10.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 2.0),
        borderRadius: BorderRadius.circular(10.0),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
    
    // Button style
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: primaryPurple,
      foregroundColor: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: const EdgeInsets.symmetric(vertical: 15),
    );
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vendor Registration',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: darkPurple,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, accentPurple!.withOpacity(0.2)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Header
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: lightPurple.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'Join Our Vendor Network',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: darkPurple,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Form Fields
                Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: darkPurple,
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _nameController,
                  decoration: inputDecoration.copyWith(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person, color: primaryPurple),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: inputDecoration.copyWith(
                    labelText: 'Address',
                    prefixIcon: Icon(Icons.home, color: primaryPurple),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter your address' : null,
                ),
                const SizedBox(height: 25),
                
                Text(
                  'Professional Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: darkPurple,
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _expertiseController,
                  decoration: inputDecoration.copyWith(
                    labelText: 'Expertise',
                    prefixIcon: Icon(Icons.work, color: primaryPurple),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter your expertise' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _experienceController,
                  decoration: inputDecoration.copyWith(
                    labelText: 'Experience (Years)',
                    prefixIcon: Icon(Icons.timeline, color: primaryPurple),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Please enter your experience' : null,
                ),
                const SizedBox(height: 25),
                
                Text(
                  'Contact Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: darkPurple,
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _phoneController,
                  decoration: inputDecoration.copyWith(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone, color: primaryPurple),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value!.isEmpty ? 'Please enter your phone number' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: inputDecoration.copyWith(
                    labelText: 'Email ID',
                    prefixIcon: Icon(Icons.email, color: primaryPurple),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value!.isEmpty ? 'Please enter your email ID' : null,
                ),
                const SizedBox(height: 25),
                
                // Certificate Upload
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: lightPurple.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: lightPurple, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Certification',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: darkPurple,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: _pickFile,
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Upload Certificate'),
                        style: buttonStyle,
                      ),
                      if (_selectedFile != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: accentPurple),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green[600]),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Selected File: $_selectedFile',
                                  style: const TextStyle(fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                
                // Register Button
                SizedBox(
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: _registerVendor,
                    icon: const Icon(Icons.app_registration, size: 24),
                    label: const Text(
                      'REGISTER',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkPurple,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
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