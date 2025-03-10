import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class OTPService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize notifications
  static Future<void> initializeNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _notificationsPlugin.initialize(settings);
  }

  // Generate OTP, store it in Firestore, and show notification
  static Future<void> generateOTP(String bookingId) async {
    final int otp = Random().nextInt(900000) + 100000; // Generate 6-digit OTP

    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({'otp': otp});

      debugPrint("OTP Generated: $otp for booking: $bookingId");

      // Show OTP notification
      _showOTPNotification(otp);
    } catch (e) {
      debugPrint("Error generating OTP: $e");
    }
  }

  // Show OTP notification
  static Future<void> _showOTPNotification(int otp) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'otp_channel', // Channel ID
      'OTP Notifications', // Channel Name
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      0, // Notification ID
      "Your OTP Code",
      "Use this OTP: $otp",
      notificationDetails,
    );
  }

  // Verify OTP
  static Future<bool> verifyOTP(String bookingId, int enteredOTP) async {
    try {
      DocumentSnapshot bookingDoc = await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .get();

      if (bookingDoc.exists) {
        final int storedOTP = bookingDoc['otp'] ?? -1;
        return storedOTP == enteredOTP;
      }
    } catch (e) {
      debugPrint("Error verifying OTP: $e");
    }
    return false;
  }
}
