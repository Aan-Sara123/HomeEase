// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../authentication/firestore_service.dart';
import 'dart:developer';
import 'vendor_login.dart';

class LocationService {
  static const String apiUrl = 'https://phonevalidation.abstractapi.com/v1/';
  static const String apiKey = 'b25cc1e2e72c4c0a85e03210644ec208';

  static Future<Map<String, dynamic>> getLocation(String phoneNumber) async {
    final url = Uri.parse('$apiUrl?api_key=$apiKey&phone=$phoneNumber');

    try {
      final response = await http.get(url);

      log('Response Status: ${response.statusCode}');
      log('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String location = data['location'] ?? 'Unknown';
        String region = data['country']?['name'] ?? 'Unknown';

        if (location.contains(',')) {
          location = location.split(',').first.trim();
        }

        return {
          'city': location,
          'region': region,
        };
      } else {
        log('Error: ${response.body}');
        throw Exception('Failed to fetch location');
      }
    } catch (e) {
      log('Exception: $e');
      return {'city': 'Unknown', 'region': 'Unknown'};
    }
  }
}

class VendorRegistration extends StatefulWidget {
  const VendorRegistration({super.key});

  @override
  VendorRegistrationState createState() => VendorRegistrationState();
}

class VendorRegistrationState extends State<VendorRegistration> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _expertiseController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  bool _isFetchingLocation = false;
  String _selectedCountryCode = '+1';
  final List<String> _countryCodes = ['+1', '+44', '+91', '+61', '+81', '+86'];

  Future<void> _fetchLocation() async {
    final phoneNumber = '$_selectedCountryCode${_phoneController.text}';
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a phone number first'),
          backgroundColor: Color(0xFF673AB7),
        ),
      );
      return;
    }

    setState(() => _isFetchingLocation = true);
    final locationData = await LocationService.getLocation(phoneNumber);
    setState(() {
      _isFetchingLocation = false;
      _locationController.text = '${locationData['city']}, ${locationData['region']}';
    });
  }

  void _registerVendor() {
    if (_formKey.currentState?.validate() ?? false) {
      final Map<String, dynamic> vendorData = {
        'name': _nameController.text,
        'phoneNumber': '$_selectedCountryCode${_phoneController.text}',
        'location': _locationController.text,
        'expertise': _expertiseController.text,
      };
      _firestoreService.addVendor(vendorData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vendor Registered Successfully!'),
          backgroundColor: Color(0xFF673AB7),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vendor Registration', 
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            color: Colors.white,
            fontSize: 20,
            letterSpacing: 0.5,
          )
        ),
        backgroundColor: const Color(0xFF673AB7), // Deep Purple
        elevation: 0,
        centerTitle: true,
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Join Our Vendor Network',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF673AB7), // Deep Purple
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Complete your profile to connect with customers',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF9E9E9E), // Grey
                        ),
                      ),
                      const SizedBox(height: 25),
                      _buildTextField(_nameController, 'Name'),
                      _buildPhoneField(),
                      _buildFetchLocationButton(),
                      _buildTextField(_locationController, 'Location', readOnly: true),
                      _buildTextField(_expertiseController, 'Expertise'),
                      const SizedBox(height: 30),
                      _buildRegisterButton(),
                      _buildLoginButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool readOnly = false}) {
    return Column(
      children: [
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Color(0xFF673AB7)), // Deep Purple
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF9C27B0), width: 2), // Purple
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: const Color(0xFFD1C4E9).withOpacity(0.5)), // Light purple
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          style: const TextStyle(color: Color(0xFF424242)), // Dark grey
          readOnly: readOnly,
          validator: (value) => value?.isEmpty ?? true ? 'Please enter $label' : null,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      children: [
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD1C4E9).withOpacity(0.5)), // Light purple
                borderRadius: BorderRadius.circular(4),
                color: Colors.white,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
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
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF9C27B0), width: 2), // Purple
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: const Color(0xFFD1C4E9).withOpacity(0.5)), // Light purple
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Color(0xFF424242)), // Dark grey
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildFetchLocationButton() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isFetchingLocation ? null : _fetchLocation,
            icon: _isFetchingLocation 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.location_on),
            label: Text(_isFetchingLocation ? 'Fetching...' : 'Fetch Location'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9C27B0), // Purple
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 3,
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _registerVendor,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF673AB7), // Deep Purple
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 5,
        ),
        child: const Text(
          'Register Vendor',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Center(
        child: TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const VendorLoginPage()),
          ),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF9C27B0), // Purple
          ),
          child: const Text(
            'Already Registered? Login Here',
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}