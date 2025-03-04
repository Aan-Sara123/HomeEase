import 'package:flutter/material.dart';
import 'contact_service.dart';
import 'contact_us_styles.dart';

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
      appBar: AppBar(
        title: const Text("Contact Us"),
        backgroundColor: ContactUsStyles.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey[50],
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: ContactUsStyles.contactCardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Contact Information",
                        style: ContactUsStyles.sectionTitleStyle,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "📍 Address: 123 HomeEase Street, City",
                        style: ContactUsStyles.contactInfoStyle,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "📞 Phone: +1 234 567 890",
                        style: ContactUsStyles.contactInfoStyle,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "✉ Email: support@homeease.com",
                        style: ContactUsStyles.contactInfoStyle,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: ContactUsStyles.contactCardDecoration,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Send Us a Message",
                          style: ContactUsStyles.sectionTitleStyle,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _nameController,
                          decoration: ContactUsStyles.inputDecoration("Name"),
                          validator: (value) => value!.isEmpty ? "Enter your name" : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _emailController,
                          decoration: ContactUsStyles.inputDecoration("Email"),
                          validator: (value) => value!.isEmpty ? "Enter a valid email" : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _messageController,
                          decoration: ContactUsStyles.inputDecoration("Message"),
                          maxLines: 4,
                          validator: (value) => value!.isEmpty ? "Enter your message" : null,
                        ),
                        const SizedBox(height: 25),
                        ElevatedButton(
                          onPressed: _submitForm,
                          style: ContactUsStyles.elevatedButtonStyle,
                          child: const Text("Send Message"),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}