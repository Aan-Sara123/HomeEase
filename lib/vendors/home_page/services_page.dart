import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class VendorRegistrationPage extends StatefulWidget {
  const VendorRegistrationPage({super.key});

  @override
  VendorRegistrationPageState createState() => VendorRegistrationPageState();
}

class VendorRegistrationPageState extends State<VendorRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedFile;

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = result.files.single.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Registration'),
        centerTitle: true,
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) => value!.isEmpty ? 'Please enter your address' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Expertise'),
                validator: (value) => value!.isEmpty ? 'Please enter your expertise' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Experience (Years)'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter your experience' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Please enter your phone number' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email ID'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty ? 'Please enter your email ID' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickFile,
                child: const Text('Upload Certificate'),
              ),
              if (_selectedFile != null) ...[
                const SizedBox(height: 10),
                Text('Selected File: $_selectedFile', style: const TextStyle(fontSize: 16)),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Handle form submission
                  }
                },
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
