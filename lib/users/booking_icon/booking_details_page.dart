// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'booking_database.dart';
import 'payment_service.dart';
import 'rating_service.dart';
import 'otp_service.dart';
import 'notification_service.dart';
import 'auth_service.dart'; // For checking admin role

class BookingDetailsPage extends StatelessWidget {
  const BookingDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Bookings",
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        backgroundColor: const Color(0xFF673AB7), // Deep Purple
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFFF3E5F5), Colors.white], // Light purple
          ),
        ),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: BookingDatabase.streamBookings(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF673AB7)),
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text("Error: ${snapshot.error}",
                    style: const TextStyle(fontSize: 16, color: Colors.red)),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text("No bookings found.",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              );
            }

            final bookings = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return _buildBookingCard(context, booking);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, Map<String, dynamic> booking) {
    final String status = booking['status'] ?? "Pending";
    final bool isServiceCompleted = status == 'Completed';
    final bool isAdmin = AuthService.isAdmin(); // Check if user is admin

    // Status colors
    final Map<String, Color> statusColors = {
      'Accepted': const Color(0xFF4CAF50),
      'Completed': const Color(0xFF3F51B5),
      'Pending': const Color(0xFFFF9800),
      'Cancelled': const Color(0xFFF44336),
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: const Color(0xFFD1C4E9), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBookingHeader(booking, statusColors[status] ?? Colors.grey),
            const SizedBox(height: 16),
            _buildBookingDetails(booking),
            const SizedBox(height: 20),
            if (status == 'Accepted')
              _buildActionButton(
                text: "Mark as Completed",
                icon: Icons.check_circle_outline,
                color: const Color(0xFFFF9800),
                onPressed: () {
                  BookingDatabase.markServiceCompleted(booking['id'], booking['userId']);
                  NotificationService.sendUserNotification(
                      booking['userId'], "Your service has been completed.");
                },
              ),
            if (isServiceCompleted)
              _buildActionButton(
                text: "Generate OTP",
                icon: Icons.vpn_key,
                color: const Color(0xFF673AB7),
                onPressed: () => OTPService.generateOTP(booking['id']),
              ),
            _buildActionButton(
              text: "Make Payment",
              icon: Icons.payment,
              color: const Color(0xFF9C27B0),
              onPressed: () => PaymentService.processPayment(booking['id']),
            ),
            _buildActionButton(
              text: "Rate Service",
              icon: Icons.star_border,
              color: const Color(0xFF7E57C2),
              onPressed: () =>
                  RatingService.showRatingDialog(context, booking['id']),
            ),
            if (isAdmin) _buildAdminActions(booking),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingHeader(Map<String, dynamic> booking, Color statusColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            booking['serviceName'] ?? "Service",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A148C),
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor),
          ),
          child: Text(
            booking['status'] ?? "Pending",
            style: TextStyle(fontWeight: FontWeight.bold, color: statusColor),
          ),
        ),
      ],
    );
  }

  Widget _buildBookingDetails(Map<String, dynamic> booking) {
    return Column(
      children: [
        _buildInfoRow(Icons.calendar_today, "Date", booking['date'] ?? "N/A"),
        _buildInfoRow(Icons.access_time, "Time", booking['time'] ?? "N/A"),
        _buildInfoRow(Icons.person, "Vendor", booking['vendor_name'] ?? "N/A"),
        _buildInfoRow(Icons.phone, "Vendor Contact",
            booking['vendor_phone'] ?? "N/A"),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF9575CD)),
          const SizedBox(width: 12),
          Text(
            "$label: ",
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF673AB7),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, color: Color(0xFF424242)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminActions(Map<String, dynamic> booking) {
    return Column(
      children: [
        _buildActionButton(
          text: "Cancel Booking",
          icon: Icons.cancel,
          color: Colors.red,
          onPressed: () {
            BookingDatabase.cancelBooking(booking['id'], booking['userId']);
            NotificationService.sendUserNotification(
                booking['userId'], "Your booking has been canceled.");
          },
        ),
      ],
    );
  }
}
