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
      final serviceAccount = await rootBundle.loadString(serviceAccountPath); // ✅ Corrected for Flutter assets
      final credentials = ServiceAccountCredentials.fromJson(serviceAccount);

      final client = await clientViaServiceAccount(
        credentials,
        ['https://www.googleapis.com/auth/firebase.messaging'],
      );

      final accessToken = client.credentials.accessToken.data;
      client.close(); // ✅ Close client to prevent memory leaks

      return accessToken;
    } catch (e) {
      debugPrint("❌ Error obtaining access token: $e");
      rethrow;
    }
  }

  /// 🔹 Save booking details to Firestore
  Future<void> saveBooking(String userId, String serviceName, String date, String time, String fcmToken) async {
    try {
      await _firestore.collection("bookings").add({
        "userId": userId,
        "serviceName": serviceName,
        "date": date,
        "time": time,
        "createdAt": FieldValue.serverTimestamp(),
      });

      debugPrint("✅ Booking saved successfully");

      // After saving booking, send notification
      await sendFCMNotification(fcmToken, serviceName, date, time);
    } catch (e) {
      debugPrint("❌ Error saving booking: $e");
    }
  }

  /// 🔹 Send a push notification using FCM v1 API
  Future<void> sendFCMNotification(String fcmToken, String serviceName, String date, String time) async {
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
              'body': 'Your $serviceName booking is confirmed for $date at $time.',
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
        debugPrint("✅ Notification sent successfully");
      } else {
        debugPrint("❌ Error sending notification: ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ Exception while sending notification: $e");
    }
  }
}

