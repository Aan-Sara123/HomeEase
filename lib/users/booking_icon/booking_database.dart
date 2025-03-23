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
  static Future<void> markServiceCompleted(String bookingId, String userId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': 'Completed',
      });

      // Send notification to user
      await sendNotification(userId, "Your booking #$bookingId has been completed.");

      _logger.i("Service marked as Completed for Booking ID: $bookingId");
    } catch (e) {
      _logger.e("Error updating service status", error: e);
    }
  }

  // Function to cancel a booking
  static Future<void> cancelBooking(String bookingId, String userId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).delete();

      // Send notification to user
      await sendNotification(userId, "Your booking #$bookingId has been canceled.");

      _logger.i("Booking canceled: $bookingId");
    } catch (e) {
      _logger.e("Error canceling booking", error: e);
    }
  }

  // Function to update vendor details in a booking
  static Future<void> updateVendorDetails(String bookingId, String vendorName, String vendorContact) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'vendor_name': vendorName,
        'vendor_contact': vendorContact,
      });
      _logger.i("Vendor details updated for Booking ID: $bookingId");
    } catch (e) {
      _logger.e("Error updating vendor details", error: e);
    }
  }

  // Admin function to approve or reject a booking
  static Future<void> updateBookingStatus(String bookingId, String status, String userId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': status,
      });

      // Notify user
      await sendNotification(userId, "Your booking #$bookingId status changed to: $status");

      _logger.i("Booking status updated: $status for Booking ID: $bookingId");
    } catch (e) {
      _logger.e("Error updating booking status", error: e);
    }
  }

  // Function to send notifications to users
  static Future<void> sendNotification(String userId, String message) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _logger.i("Notification sent to User ID: $userId - Message: $message");
    } catch (e) {
      _logger.e("Error sending notification", error: e);
    }
  }
}
