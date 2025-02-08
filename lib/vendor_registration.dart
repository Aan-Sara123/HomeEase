import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'firestore_service.dart';

/// Vendor Registration - Handles Vendor Registration logic
class VendorRegistration extends StatefulWidget {
  const VendorRegistration({super.key});

  @override
  VendorRegistrationState createState() => VendorRegistrationState();
}

class VendorRegistrationState extends State<VendorRegistration> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _vendorNameController = TextEditingController();
  final TextEditingController _vendorEmailController = TextEditingController();
  final TextEditingController _vendorLocationController = TextEditingController();
  final TextEditingController _vendorExpertiseController = TextEditingController();
  final TextEditingController _vendorExperienceController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  final String _numverifyApiKey = 'ca7affef33f5e3bff0922bb64d9a8a7d'; // Replace with your actual API key

  void _registerVendor() {
    if (_formKey.currentState?.validate() ?? false) {
      final Map<String, dynamic> vendorData = {
        'vendor_name': _vendorNameController.text,
        'vendor_email': _vendorEmailController.text,
        'vendor_location': _vendorLocationController.text,
        'vendor_expertise': _vendorExpertiseController.text,
        'vendor_experience': _vendorExperienceController.text,
      };

      _firestoreService.addVendor(vendorData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vendor Registered Successfully!')),
      );
    }
  }

  Future<void> _fetchPhoneNumberDetails(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a phone number')),
      );
      return;
    }

    final url =
        'http://apilayer.net/api/validate?access_key=$_numverifyApiKey&number=$phoneNumber';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['valid'] == true) {
          if (!mounted) return;
          setState(() {
            _vendorLocationController.text =
                '${data['country_name']} (${data['location'] ?? 'Unknown'})';
          });
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid phone number')),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch phone number details')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching phone number details')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vendor Registration')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Register New Vendor',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _vendorNameController,
                      decoration: const InputDecoration(labelText: 'Vendor Name'),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Please enter vendor name' : null,
                    ),
                    TextFormField(
                      controller: _vendorEmailController,
                      decoration: const InputDecoration(labelText: 'Vendor Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Please enter vendor email' : null,
                    ),
                    TextFormField(
                      controller: _phoneNumberController,
                      decoration: const InputDecoration(labelText: 'Phone Number'),
                      keyboardType: TextInputType.phone,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Please enter phone number' : null,
                    ),
                    TextFormField(
                      controller: _vendorLocationController,
                      decoration: const InputDecoration(labelText: 'Location'),
                      readOnly: true,
                    ),
                    TextFormField(
                      controller: _vendorExpertiseController,
                      decoration: const InputDecoration(labelText: 'Expertise'),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Please enter vendor expertise' : null,
                    ),
                    TextFormField(
                      controller: _vendorExperienceController,
                      decoration: const InputDecoration(labelText: 'Experience'),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Please enter vendor experience' : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 40),
                      ),
                      onPressed: () =>
                          _fetchPhoneNumberDetails(_phoneNumberController.text),
                      child: const Text('Fetch Location'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 40),
                      ),
                      onPressed: _registerVendor,
                      child: const Text('Register Vendor'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
