import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static const String _serverKey = "YOUR_FCM_SERVER_KEY"; // 🔴 Replace this with your actual FCM Server Key

  /// 🔹 Request notification permissions
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

  /// 🔹 Store the user's FCM token in Firestore
  Future<void> storeUserFcmToken() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String? token = await _messaging.getToken();
        if (token != null) {
          await _firestore.collection('users').doc(user.uid).set(
            {'fcmToken': token},
            SetOptions(merge: true),
          );
          debugPrint("✅ User's FCM token updated: $token");
        }
      }
    } catch (e) {
      debugPrint("❌ Error storing FCM token: $e");
    }
  }

  /// 🔹 Save booking and send notification
  Future<void> saveBooking(String serviceName, String date, String time) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Store booking details in Firestore
        await _firestore.collection('users').doc(user.uid).update({
          'bookings': FieldValue.arrayUnion([
            {'serviceName': serviceName, 'date': date, 'time': time}
          ]),
        });

        // Retrieve FCM token and send notification
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        String? fcmToken = userDoc['fcmToken'];

        if (fcmToken != null) {
          await _sendFCMNotification(fcmToken, serviceName, date, time);
        } else {
          debugPrint('No FCM token found for user: ${user.email}');
        }
      }
    } catch (e) {
      debugPrint('❌ Error saving booking: $e');
    }
  }

  /// 🔹 Send notification using Firebase Cloud Messaging
  Future<void> _sendFCMNotification(String fcmToken, String serviceName, String date, String time) async {
    try {
      var response = await http.post(
        Uri.parse('https://fcm.googleapis.com/v1/projects/homeeaseapp-36aba/messages:send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$_serverKey',
        },
        body: jsonEncode({
          'to': fcmToken,
          'notification': {
            'title': 'Booking Confirmed',
            'body': 'Your $serviceName booking is confirmed for $date at $time.',
            'sound': 'default',
          },
          'priority': 'high',
        }),
      );

      if (response.statusCode == 200) {
        debugPrint("✅ Notification sent successfully");
      } else {
        debugPrint("❌ Error sending notification: ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ Exception while sending notification: $e");
    }
  }
}
