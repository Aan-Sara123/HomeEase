import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

class ContactService {
  static Future<bool> sendMessage({required String name, required String email, required String message}) async {
    try {
      await FirebaseFirestore.instance.collection('contact_messages').add({
        'name': name,
        'email': email,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });

      developer.log("Message sent successfully");
      return true;
    } catch (e) {
      developer.log("Error sending message", error: e);
      return false;
    }
  }
}
