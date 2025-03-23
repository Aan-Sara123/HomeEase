// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingDetailsPage extends StatefulWidget {
  final String bookingId;
  final Map<String, dynamic> bookingData;

  const BookingDetailsPage({
    super.key,
    required this.bookingId,
    required this.bookingData,
  });

  @override
  State<BookingDetailsPage> createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> {
  bool _isUpdating = false;
  bool _showOTPField = false;
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _vendorNameController = TextEditingController();
  final TextEditingController _vendorPhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _showOTPField = widget.bookingData['status'] == 'Accepted';
    
    // Initialize vendor information if available
    _vendorNameController.text = widget.bookingData['vendor_name'] ?? '';
    _vendorPhoneController.text = widget.bookingData['vendor_phone'] ?? '';
  }

  /// Updates the booking status in Firestore
  Future<void> _updateBookingStatus(String status) async {
    if (!mounted) return;

    setState(() => _isUpdating = true);

    try {
      // Update vendor information along with status
      Map<String, dynamic> updateData = {
        'status': status,
        'vendor_name': _vendorNameController.text.trim(),
        'vendor_phone': _vendorPhoneController.text.trim(),
      };

      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .update(updateData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Booking $status successfully!")),
        );

        // Refresh UI after status change
        setState(() {
          if (status == 'Accepted') {
            _showOTPField = true;
          }
        });

        if (status == 'Completed' || status == 'Rejected') {
          Navigator.pop(context);
        }
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

  Future<void> _cancelBooking() async {
    if (!mounted) return;

    setState(() => _isUpdating = true);

    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Booking cancelled successfully!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to cancel booking: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  /// Verifies the OTP entered by the vendor
  Future<void> _verifyOTP() async {
    if (!mounted) return;

    String enteredOTP = _otpController.text.trim();
    if (enteredOTP.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter OTP")),
      );
      return;
    }

    try {
      DocumentSnapshot bookingDoc = await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .get();

      /// Convert OTP to string to avoid type mismatch errors
      String correctOTP = bookingDoc['otp'].toString();

      if (enteredOTP == correctOTP) {
        await _updateBookingStatus("Completed");
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid OTP. Please try again.")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error verifying OTP: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String status = widget.bookingData['status'] ?? 'Pending';
    bool isAdmin = widget.bookingData['role'] == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF5F0FF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service details card
            _infoCard(status),
            
            // Vendor information card
            if (!isAdmin) _vendorInfoCard(),

            // OTP Section (only for Accepted bookings)
            if (_showOTPField) _otpVerificationCard(),

            // Action buttons for vendor/admin
            if (!isAdmin) _vendorActions(status),
            if (isAdmin) _adminActions(),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String status) {
    return Container(
      width: double.infinity,
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _titleRow("Booking Information", status),
          const Divider(height: 24),
          _infoRow("Service", widget.bookingData['serviceName'] ?? 'N/A'),
          _infoRow("Date", widget.bookingData['date'] ?? 'N/A'),
          _infoRow("Time", widget.bookingData['time'] ?? 'N/A'),
          _infoRow("Contact", widget.bookingData['userContact'] ?? 'N/A'),
          _infoRow("Address", widget.bookingData['address'] ?? 'Not provided'),
        ],
      ),
    );
  }

  Widget _vendorInfoCard() {
    return Container(
      width: double.infinity,
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("Vendor Information"),
          const SizedBox(height: 16),
          const Text("Please provide your information:"),
          const SizedBox(height: 12),
          
          // Vendor name field
          TextField(
            controller: _vendorNameController,
            decoration: _inputDecoration("Full Name"),
            keyboardType: TextInputType.name,
          ),
          const SizedBox(height: 12),
          
          // Vendor phone field
          TextField(
            controller: _vendorPhoneController,
            decoration: _inputDecoration("Contact Number"),
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _otpVerificationCard() {
    return Container(
      width: double.infinity,
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("Verify Completion"),
          const SizedBox(height: 12),
          const Text("Enter OTP to confirm service completion:"),
          const SizedBox(height: 8),
          TextField(
            controller: _otpController,
            decoration: _inputDecoration("Enter OTP"),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          _actionButton("Verify OTP", _verifyOTP, Colors.purple[700]!),
        ],
      ),
    );
  }

  Widget _vendorActions(String status) {
    return Container(
      width: double.infinity,
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("Actions"),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  "Accept", 
                  () {
                    // Validate vendor info before accepting
                    if (_vendorNameController.text.trim().isEmpty || 
                        _vendorPhoneController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please fill in your name and contact number")),
                      );
                      return;
                    }
                    _updateBookingStatus('Accepted');
                  },
                  Colors.green
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionButton(
                  "Reject",
                  () => _updateBookingStatus('Rejected'),
                  Colors.red
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _adminActions() {
    return Container(
      width: double.infinity,
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: _actionButton("Cancel Booking", _cancelBooking, Colors.orange),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              "$label:",
              style: _labelStyle(),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      hintText: hint,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.purple[700]!),
      ),
    );
  }

  Widget _actionButton(String text, VoidCallback onPressed, Color color) {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton(
        onPressed: _isUpdating ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isUpdating && text == "Verify OTP"
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(text),
      ),
    );
  }

  TextStyle _labelStyle() => TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.purple[700],
      );

  Widget _sectionTitle(String title) => Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.purple[900],
        ),
      );

  Widget _titleRow(String title, String status) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.purple[900],
            ),
          ),
          _statusBadge(status),
        ],
      );

  Widget _statusBadge(String status) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: status == 'Accepted'
              ? Colors.green
              : (status == 'Rejected' ? Colors.red : Colors.purple[700]),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          status,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      );

  @override
  void dispose() {
    _otpController.dispose();
    _vendorNameController.dispose();
    _vendorPhoneController.dispose();
    super.dispose();
  }
}