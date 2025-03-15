import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class FirebaseService {
  final String projectId = "homeeaseapp-36aba"; // 🔴 Replace with your Firebase Project ID
  final String serviceAccountPath = "assets/service-account.json"; // 🔴 Path to service account JSON
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔹 Authenticate and obtain an OAuth token using clientViaServiceAccount
  Future<String> getAccessToken() async {
    try {
      final serviceAccount = await rootBundle.loadString(serviceAccountPath);
      final credentials = ServiceAccountCredentials.fromJson(serviceAccount);

      final client = await clientViaServiceAccount(
        credentials,
        ['https://www.googleapis.com/auth/firebase.messaging'],
      );

      final accessToken = client.credentials.accessToken.data;
      client.close(); 

      return accessToken;
    } catch (e) {
      debugPrint("❌ Error obtaining access token: $e");
      rethrow;
    }
  }

  /// 🔹 Save booking details to Firestore and return booking ID
  Future<String> saveBooking(String userId, String serviceName, String date, String time, String address, String fcmToken) async {
    try {
      DocumentReference bookingRef = await _firestore.collection("bookings").add({
        "userId": userId,
        "serviceName": serviceName,
        "date": date,
        "time": time,
        "address": address, // 🔹 Save address field
        "fcmToken": fcmToken, // 🔹 Save FCM token for cancellation notification
        "createdAt": FieldValue.serverTimestamp(),
      });

      String bookingId = bookingRef.id;
      debugPrint("✅ Booking saved successfully: $bookingId");

      await sendFCMNotification(fcmToken, serviceName, date, time, address);

      return bookingId; // Return booking ID
    } catch (e) {
      debugPrint("❌ Error saving booking: $e");
      rethrow;
    }
  }

  /// 🔹 Cancel a booking and send notification
  Future<void> cancelBooking(String bookingId) async {
    try {
      DocumentSnapshot bookingSnapshot = await _firestore.collection("bookings").doc(bookingId).get();

      if (!bookingSnapshot.exists) {
        debugPrint("❌ Booking not found.");
        return;
      }

      String fcmToken = bookingSnapshot['fcmToken'];
      String serviceName = bookingSnapshot['serviceName'];
      String date = bookingSnapshot['date'];
      String time = bookingSnapshot['time'];
      String address = bookingSnapshot['address'];

      // Delete booking from Firestore
      await _firestore.collection("bookings").doc(bookingId).delete();
      debugPrint("✅ Booking canceled successfully");

      // Send cancellation notification
      await sendCancellationNotification(fcmToken, serviceName, date, time, address);
    } catch (e) {
      debugPrint("❌ Error canceling booking: $e");
    }
  }

  /// 🔹 Send a booking confirmation notification
  Future<void> sendFCMNotification(String fcmToken, String serviceName, String date, String time, String address) async {
    try {
      final String accessToken = await getAccessToken();
      final String url = 'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'message': {
            'token': fcmToken,
            'notification': {
              'title': 'Booking Confirmed',
              'body': 'Your $serviceName booking is confirmed for $date at $time at $address.',
            },
            'android': {
              'priority': 'high',
            },
            'apns': {
              'headers': {'apns-priority': '10'},
            },
          },
        }),
      );

      if (response.statusCode == 200) {
        debugPrint("✅ Booking notification sent successfully");
      } else {
        debugPrint("❌ Error sending booking notification: ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ Exception while sending notification: $e");
    }
  }

  /// 🔹 Send a cancellation notification
  Future<void> sendCancellationNotification(String fcmToken, String serviceName, String date, String time, String address) async {
    try {
      final String accessToken = await getAccessToken();
      final String url = 'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'message': {
            'token': fcmToken,
            'notification': {
              'title': 'Booking Canceled',
              'body': 'Your $serviceName booking on $date at $time at $address has been canceled.',
            },
            'android': {
              'priority': 'high',
            },
            'apns': {
              'headers': {'apns-priority': '10'},
            },
          },
        }),
      );

      if (response.statusCode == 200) {
        debugPrint("✅ Cancellation notification sent successfully");
      } else {
        debugPrint("❌ Error sending cancellation notification: ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ Exception while sending cancellation notification: $e");
    }
  }
}