import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingDetailsPage extends StatefulWidget {
  final String bookingId;
  final Map<String, dynamic> bookingData;

  const BookingDetailsPage(
      {super.key, required this.bookingId, required this.bookingData});

  @override
  State<BookingDetailsPage> createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> {
  bool _isUpdating = false;

  /// Updates the booking status in Firestore
  Future<void> _updateBookingStatus(String status) async {
    if (!mounted) return; // Ensure widget is still mounted

    setState(() => _isUpdating = true);

    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .update({
        'status': status,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Booking $status successfully!")),
        );
        Navigator.pop(context); // Navigate back only if mounted
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update booking: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Service: ${widget.bookingData['serviceName']}",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Date: ${widget.bookingData['date']}"),
            Text("Time: ${widget.bookingData['time']}"),
            Text("User Contact: ${widget.bookingData['userContact'] ?? 'N/A'}"),
            Text("Address: ${widget.bookingData['address'] ?? 'Not provided'}"),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _isUpdating
                      ? null
                      : () => _updateBookingStatus('Accepted'),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: _isUpdating
                      ? const CircularProgressIndicator()
                      : const Text("Accept"),
                ),
                ElevatedButton(
                  onPressed: _isUpdating
                      ? null
                      : () => _updateBookingStatus('Rejected'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: _isUpdating
                      ? const CircularProgressIndicator()
                      : const Text("Reject"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
