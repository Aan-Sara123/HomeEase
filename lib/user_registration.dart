import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'firestore_service.dart'; // Assumes you have a Firestore service to save user data

/// Location Service - Fetch location from phone number
class LocationService {
  static const String apiUrl = 'https://phonevalidation.abstractapi.com/v1/';
  static const String apiKey = 'b25cc1e2e72c4c0a85e03210644ec208'; // Your API key

  // Fetch location from phone number
 static Future<Map<String, dynamic>> getLocation(String phoneNumber) async {
  final url = Uri.parse('$apiUrl?api_key=$apiKey&phone=$phoneNumber');

  try {
    final response = await http.get(url);

    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}'); // Debugging: Log the raw response

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Extract location and country
      String location = data['location'] ?? 'Unknown'; // Full location string
      String region = data['country']?['name'] ?? 'Unknown'; // Country name

      // If the location contains a comma (e.g., "State, India"), split and take the state
      if (location.contains(',')) {
        location = location.split(',').first.trim();
      }

      return {
        'city': location, // Now 'city' contains only the state
        'region': region, // Country name
      };
    } else {
      print('Error: ${response.body}');
      throw Exception('Failed to fetch location');
    }
  } catch (e) {
    print('Exception: $e');
    return {'city': 'Unknown', 'region': 'Unknown'};
  }
}
}
/// User Registration - Handles User Registration logic
class UserRegistration extends StatefulWidget {
  const UserRegistration({super.key});

  @override
  _UserRegistrationState createState() => _UserRegistrationState();
}

class _UserRegistrationState extends State<UserRegistration> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  bool _isFetchingLocation = false;

  // Fetch location based on phone number
  Future<void> _fetchLocation() async {
    final phoneNumber = _phoneController.text;
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter a phone number first'),
      ));
      return;
    }

    setState(() => _isFetchingLocation = true);

    final locationData = await LocationService.getLocation(phoneNumber);

    setState(() {
      _isFetchingLocation = false;
      _locationController.text =
          '${locationData['city']}, ${locationData['region']}';
    });
  }

  void _registerUser() {
    if (_formKey.currentState?.validate() ?? false) {
      final Map<String, dynamic> userData = {
        'name': _nameController.text,
        'phoneNumber': _phoneController.text,
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
      appBar: AppBar(title: const Text('User Registration')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Register New User',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Please enter a name' : null,
                  ),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Please enter a phone number' : null,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _isFetchingLocation ? null : _fetchLocation,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 40),
                    ),
                    child: _isFetchingLocation
                        ? const CircularProgressIndicator()
                        : const Text('Fetch Location'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(labelText: 'Location'),
                    readOnly: true, // User can't edit this field
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Please fetch location' : null,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _registerUser,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 40),
                    ),
                    child: const Text('Register'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
