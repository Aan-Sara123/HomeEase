// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'booking_service.dart'; // Import the database service
import 'booking_styles.dart'; // Import the styles

class BookingDetailsPage extends StatelessWidget {
  const BookingDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Bookings", style: BookingStyles.appBarTitleStyle),
        backgroundColor: BookingStyles.primaryColor,
        elevation: 4,
        shadowColor: BookingStyles.primaryColor.withOpacity(0.3),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: BookingStyles.backgroundGradient,
        ),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: BookingService.streamBookings(), // Stream instead of Future
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          BookingStyles.primaryColor)),
                    const SizedBox(height: 16),
                    Text("Loading Bookings...",
                        style: BookingStyles.loadingTextStyle),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 48, color: BookingStyles.errorIconColor),
                    const SizedBox(height: 16),
                    Text("Error: ${snapshot.error}",
                        style: BookingStyles.errorTextStyle),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today,
                        size: 48, color: BookingStyles.emptyIconColor),
                    const SizedBox(height: 16),
                    Text("No bookings found",
                        style: BookingStyles.emptyTextStyle),
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
                return _buildBookingCard(booking);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    booking['serviceName'] ?? "Service",
                    style: BookingStyles.serviceNameStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: BookingStyles.getStatusColor(booking['status']),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    booking['status']?.toUpperCase() ?? "PENDING",
                    style: BookingStyles.statusTextStyle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.calendar_month,
              label: "Date:",
              value: booking['date'] ?? "N/A",
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              icon: Icons.access_time,
              label: "Time:",
              value: booking['time'] ?? "N/A",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      {required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: BookingStyles.detailIconColor),
        const SizedBox(width: 8),
        RichText(
          text: TextSpan(
            style: BookingStyles.detailTextStyle,
            children: [
              TextSpan(
                text: "$label ",
                style: BookingStyles.detailLabelStyle,
              ),
              TextSpan(
                text: value,
                style: BookingStyles.detailValueStyle,
              ),
            ],
          ),
        ),
      ],
    );
  }
}