// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

class ContactAdminPage extends StatefulWidget {
  final String vendorId;

  const ContactAdminPage({super.key, required this.vendorId});

  @override
  State<ContactAdminPage> createState() => _ContactAdminPageState();
}

class _ContactAdminPageState extends State<ContactAdminPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      bool success = await _sendMessage(
        vendorId: widget.vendorId,
        message: _messageController.text,
      );

      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Message sent to admin successfully!'),
            backgroundColor: Color(0xFF6A1B9A),
          ),
        );
        _messageController.clear();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send message. Try again later.'),
            backgroundColor: Color(0xFFAD1457),
          ),
        );
      }
    }
  }

  Future<bool> _sendMessage({
    required String vendorId,
    required String message,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('vendorMessages')
          .doc(vendorId)
          .collection('messages')
          .add({
        'message': message,
        'sender': 'vendor',
        'timestamp': FieldValue.serverTimestamp(),
      });

      developer.log("Message sent successfully");
      return true;
    } catch (e) {
      developer.log("Error sending message", error: e);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define color palette
    const primaryColor = Color(0xFF6A1B9A); // Deep Purple
    const accentColor = Color(0xFF9C27B0); // Regular Purple
    const lightPurple = Color(0xFFE1BEE7); // Light Purple
    const darkPurple = Color(0xFF4A148C); // Dark Purple

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Contact Admin",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: darkPurple.withOpacity(0.3),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, lightPurple.withOpacity(0.2)],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Send a Message to Admin",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: darkPurple,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: lightPurple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "\"Our team is ready to assist you with any questions or concerns you may have.\"",
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: accentColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: "Message",
                      labelStyle: TextStyle(color: accentColor),
                      hintText: "Type your message here...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: lightPurple),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: primaryColor, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: accentColor.withOpacity(0.5)),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      prefixIcon: const Icon(
                        Icons.message_outlined,
                        color: accentColor,
                      ),
                    ),
                    maxLines: 4,
                    validator: (value) =>
                        value!.isEmpty ? "Enter your message" : null,
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      shadowColor: darkPurple.withOpacity(0.4),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send_rounded),
                        SizedBox(width: 8),
                        Text(
                          "Send Message",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
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