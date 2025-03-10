import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentService {
  static Future<void> processPayment(String bookingId) async {
    // Placeholder for payment processing logic
    await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({'paymentStatus': 'Paid'});
    debugPrint("Payment successful for booking: $bookingId");
  }
}