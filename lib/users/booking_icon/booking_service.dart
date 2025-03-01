import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

class BookingService {
  static Stream<List<Map<String, dynamic>>> streamBookings() {
    try {
      return FirebaseFirestore.instance.collection('bookings').snapshots().map(
        (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
      );
    } catch (e) {
      developer.log("Error streaming bookings", error: e);
      return const Stream.empty();
    }
  }
}
