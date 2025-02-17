import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../authentication/firestore_service.dart';
import 'dart:developer';
import 'login_page1.dart';

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

class UserRegistration extends StatefulWidget {
  const UserRegistration({super.key});

  @override
  UserRegistrationState createState() => UserRegistrationState();
}

class UserRegistrationState extends State<UserRegistration> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  bool _isFetchingLocation = false;
  String _selectedCountryCode = '+1';

  final List<String> _countryCodes = ['+1', '+44', '+91', '+61', '+81', '+86'];

  Future<void> _fetchLocation() async {
    final phoneNumber = '$_selectedCountryCode${_phoneController.text}';
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a phone number first')),
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

  void _registerUser() {
    if (_formKey.currentState?.validate() ?? false) {
      final Map<String, dynamic> userData = {
        'name': _nameController.text,
        'phoneNumber': '$_selectedCountryCode${_phoneController.text}',
        'location': _locationController.text,
      };

      _firestoreService.addUser(userData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User Registered Successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Registration', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.teal,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal, Colors.white],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'Register New User',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          labelStyle: const TextStyle(color: Colors.teal),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.teal),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.teal, width: 2),
                          ),
                        ),
                        validator: (value) => value?.isEmpty ?? true ? 'Please enter a name' : null,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          DropdownButton<String>(
                            value: _selectedCountryCode,
                            onChanged: (String? newValue) {
                              setState(() => _selectedCountryCode = newValue!);
                            },
                            items: _countryCodes.map<DropdownMenuItem<String>>(
                              (String value) => DropdownMenuItem<String>(
                                value: value,
                                child: Text(value, style: const TextStyle(color: Colors.teal)),
                              ),
                            ).toList(),
                            dropdownColor: Colors.white,
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.teal),
                            style: const TextStyle(color: Colors.teal),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              decoration: InputDecoration(
                                labelText: 'Phone Number',
                                labelStyle: const TextStyle(color: Colors.teal),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Colors.teal),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Colors.teal, width: 2),
                                ),
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (value) => value?.isEmpty ?? true ? 'Please enter a phone number' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isFetchingLocation ? null : _fetchLocation,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isFetchingLocation
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Fetch Location', style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          labelText: 'Location',
                          labelStyle: const TextStyle(color: Colors.teal),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.teal),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.teal, width: 2),
                          ),
                        ),
                        readOnly: true,
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: ElevatedButton(
                          onPressed: _registerUser,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: Colors.teal,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Register', style: TextStyle(fontSize: 18)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginPage()),
                            );
                          },
                          child: const Text(
                            'Already Registered? Login Here',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal),
                          ),
                        ),
                      ),
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
}