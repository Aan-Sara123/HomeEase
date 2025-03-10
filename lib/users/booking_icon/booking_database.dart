import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

class BookingDatabase {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final Logger _logger = Logger(); // Logger instance

  // Stream for listening to booking updates
  static Stream<List<Map<String, dynamic>>> streamBookings() {
    return _firestore.collection('bookings').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    });
  }

  // Function to mark a service as "Completed"
  static Future<void> markServiceCompleted(String bookingId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': 'Completed',
      });
      _logger.i("Service marked as Completed for Booking ID: $bookingId"); // Info log
    } catch (e) {
      _logger.e("Error updating service status", error: e);
    }
  }
}
