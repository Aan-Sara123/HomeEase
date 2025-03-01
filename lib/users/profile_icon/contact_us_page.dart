import 'package:flutter/material.dart';
import 'contact_service.dart'; // Handles form submission

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  ContactUsPageState createState() => ContactUsPageState();
}

class ContactUsPageState extends State<ContactUsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      bool success = await ContactService.sendMessage(
        name: _nameController.text,
        email: _emailController.text,
        message: _messageController.text,
      );

      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message sent successfully!')),
        );
        _nameController.clear();
        _emailController.clear();
        _messageController.clear();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send message. Try again later.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Contact Us")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Contact Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("📍 Address: 123 HomeEase Street, City"),
            const Text("📞 Phone: +1 234 567 890"),
            const Text("✉ Email: support@homeease.com"),
            const Divider(height: 30),
            const Text("Send Us a Message", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: "Name"),
                    validator: (value) => value!.isEmpty ? "Enter your name" : null,
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: "Email"),
                    validator: (value) => value!.isEmpty ? "Enter a valid email" : null,
                  ),
                  TextFormField(
                    controller: _messageController,
                    decoration: const InputDecoration(labelText: "Message"),
                    maxLines: 4,
                    validator: (value) => value!.isEmpty ? "Enter your message" : null,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text("Send Message"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}