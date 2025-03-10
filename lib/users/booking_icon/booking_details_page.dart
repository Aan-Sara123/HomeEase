// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'booking_database.dart';
import 'payment_service.dart';
import 'rating_service.dart';
import 'otp_service.dart';

class BookingDetailsPage extends StatelessWidget {
  const BookingDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Bookings",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: const Color(0xFF673AB7), // Deep Purple
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFF3E5F5), // Very light purple
              Colors.white,
            ],
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Color(0xFF9575CD),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Error: ${snapshot.error}",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF673AB7),
                      ),
                    ),
                  ],
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 60,
                      color: Color(0xFF9575CD),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "No bookings found",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF673AB7),
                      ),
                    ),
                  ],
                ),
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

    // Status colors
    final Map<String, Color> statusColors = {
      'Accepted': const Color(0xFF4CAF50),
      'Completed': const Color(0xFF3F51B5),
      'Pending': const Color(0xFFFF9800),
      'Cancelled': const Color(0xFFF44336),
    };
    
    Color statusColor = statusColors[status] ?? const Color(0xFFF44336);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 5,
      shadowColor: const Color(0xFFD1C4E9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: const Color(0xFFD1C4E9),
          width: 1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              const Color(0xFFEDE7F6), // Very light purple
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      booking['serviceName'] ?? "Service",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A148C), // Very dark purple
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
                      status,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD1C4E9).withOpacity(0.5),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.calendar_today, "Date", booking['date'] ?? "N/A"),
                    const Divider(height: 16, thickness: 0.5),
                    _buildInfoRow(Icons.access_time, "Time", booking['time'] ?? "N/A"),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Button to mark the service as completed (Only visible if status is "Accepted")
              if (status == 'Accepted')
                _buildActionButton(
                  text: "Mark as Completed",
                  icon: Icons.check_circle_outline,
                  color: const Color(0xFFFF9800),
                  onPressed: () => BookingDatabase.markServiceCompleted(booking['id']),
                ),

              // Generate OTP Button (Only if Service is Completed)
              _buildActionButton(
                text: "Generate OTP",
                icon: Icons.vpn_key,
                color: isServiceCompleted ? const Color(0xFF673AB7) : Colors.grey,
                onPressed: isServiceCompleted
                    ? () => OTPService.generateOTP(booking['id'])
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("OTP can only be generated after the service is completed."),
                            backgroundColor: Color(0xFF673AB7),
                          ),
                        );
                      },
              ),

              // Payment Button
              _buildActionButton(
                text: "Make Payment",
                icon: Icons.payment,
                color: const Color(0xFF9C27B0),
                onPressed: () => PaymentService.processPayment(booking['id']),
              ),

              // Rating Button
              _buildActionButton(
                text: "Rate Service",
                icon: Icons.star_border,
                color: const Color(0xFF7E57C2),
                onPressed: () => RatingService.showRatingDialog(context, booking['id']),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xFF9575CD),
          ),
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
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF424242),
              ),
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
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 3,
          shadowColor: color.withOpacity(0.4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}