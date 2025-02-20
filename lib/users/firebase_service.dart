import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart'; // For debug logging

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _messaging =
      FirebaseMessaging.instance; // Use FCM properly

  // Save booking details and send notification
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

        // Retrieve user's FCM token from Firestore
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        String? fcmToken = userDoc['fcmToken'];

        // Send notification if the token is available
        if (fcmToken != null) {
          await _sendBookingNotification(fcmToken, serviceName, date, time);
        } else {
          debugPrint('No FCM token found for user: ${user.email}');
        }
      }
    } catch (e) {
      debugPrint('Error saving booking: $e');
    }
  }

  // Request FCM permissions (For iOS)
  Future<void> requestNotificationPermissions() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint("✅ Notifications enabled");
    } else {
      debugPrint("❌ Notifications denied");
    }
  }

  // Send notification via Firebase Cloud Messaging
  Future<void> _sendBookingNotification(
      String fcmToken, String serviceName, String date, String time) async {
    try {
      await _firestore.collection('notifications').add({
        'to': fcmToken, // Send to user's FCM token
        'title': 'Booking Confirmed',
        'body': 'Your $serviceName booking is confirmed for $date at $time.',
        'timestamp': FieldValue.serverTimestamp(),
      });

      debugPrint("✅ Notification sent to $fcmToken");
    } catch (e) {
      debugPrint("❌ Error sending notification: $e");
    }
  }

  // Store the FCM token for the user
  Future<void> storeUserFcmToken() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String? token = await _messaging.getToken();
        if (token != null) {
          await _firestore.collection('users').doc(user.uid).update({
            'fcmToken': token,
          });
          debugPrint("✅ User's FCM token updated: $token");
        }
      }
    } catch (e) {
      debugPrint("❌ Error storing FCM token: $e");
    }
  }
}
