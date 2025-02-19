import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Save booking details to the user's document
  Future<void> saveBooking(String serviceName, String date, String time) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Save booking under the user's document
        await _firestore.collection('users').doc(user.uid).update({
          'bookings': FieldValue.arrayUnion([
            {
              'serviceName': serviceName,
              'date': date,
              'time': time,
            }
          ]),
        });

        // Send push notification (fetch FCM token first)
        String? fcmToken =
            await _messaging.getToken(); // Directly fetch the token
        if (fcmToken != null) {
          await _sendBookingNotification(fcmToken, serviceName, date, time);
        }
      }
    } catch (e) {
      debugPrint('Error saving booking: $e');
    }
  }

  // Function to send a push notification (Assumes FCM backend is set up)
  Future<void> _sendBookingNotification(
      String fcmToken, String serviceName, String date, String time) async {
    // The correct way is to send this data via your backend or Firebase Cloud Functions
    debugPrint('Sending FCM notification to token: $fcmToken');
    debugPrint('Booking for $serviceName on $date at $time');
  }
}
