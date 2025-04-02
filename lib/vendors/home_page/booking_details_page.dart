// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

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

  // Color scheme
  final Color _primaryColor = const Color(0xFF6A1B9A);
  final Color _accentColor = const Color(0xFF9C27B0);
  final Color _lightPurple = const Color(0xFFF5F0FF);
  final Color _darkPurple = const Color(0xFF4A148C);

  @override
  void initState() {
    super.initState();
    _showOTPField = widget.bookingData['status'] == 'Accepted';
    
    // Initialize vendor information if available
    _vendorNameController.text = widget.bookingData['vendor_name'] ?? '';
    _vendorPhoneController.text = widget.bookingData['vendor_phone'] ?? '';
  }

  /// Opens Google Maps with the provided address or coordinates
  Future<void> _openGoogleMaps(String address) async {
    String encodedAddress = Uri.encodeComponent(address);
    Uri googleMapsUri = Uri.parse("https://www.google.com/maps/search/?api=1&query=$encodedAddress");

    if (!await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open Google Maps")),
      );
    }
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
          SnackBar(
            content: Text("Booking $status successfully!"),
            backgroundColor: _accentColor,
          ),
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
          SnackBar(
            content: Text("Failed to update booking: $e"),
            backgroundColor: Colors.red,
          ),
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
          SnackBar(
            content: const Text("Booking cancelled successfully!"),
            backgroundColor: _accentColor,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to cancel booking: $e"),
            backgroundColor: Colors.red,
          ),
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
        const SnackBar(
          content: Text("Please enter OTP"),
          backgroundColor: Colors.orange,
        ),
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
          SnackBar(
            content: const Text("Invalid OTP. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error verifying OTP: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String status = widget.bookingData['status'] ?? 'Pending';
    bool isAdmin = widget.bookingData['role'] == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Booking Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: _lightPurple,
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
          const Divider(height: 24, thickness: 1),
          _infoRow("Service", widget.bookingData['serviceName'] ?? 'N/A'),
          _infoRow("Date", widget.bookingData['date'] ?? 'N/A'),
          _infoRow("Time", widget.bookingData['time'] ?? 'N/A'),
          _infoRow("Contact", widget.bookingData['userContact'] ?? 'N/A'),
          _clickableInfoRow("Address", widget.bookingData['address'] ?? 'Not provided'),
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
          Text(
            "Please provide your information:",
            style: TextStyle(color: _darkPurple.withOpacity(0.8)),
          ),
          const SizedBox(height: 12),
          
          // Vendor name field
          TextField(
            controller: _vendorNameController,
            decoration: _inputDecoration("Full Name", Icons.person),
            keyboardType: TextInputType.name,
          ),
          const SizedBox(height: 12),
          
          // Vendor phone field
          TextField(
            controller: _vendorPhoneController,
            decoration: _inputDecoration("Contact Number", Icons.phone),
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
          Text(
            "Enter OTP to confirm service completion:",
            style: TextStyle(color: _darkPurple.withOpacity(0.8)),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _otpController,
            decoration: _inputDecoration("Enter OTP", Icons.lock),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          _actionButton(
            "Verify OTP", 
            _verifyOTP, 
            _primaryColor,
            icon: Icons.check_circle,
          ),
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
                        const SnackBar(
                          content: Text("Please fill in your name and contact number"),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
                    _updateBookingStatus('Accepted');
                  },
                  Colors.green,
                  icon: Icons.check,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionButton(
                  "Reject",
                  () => _updateBookingStatus('Rejected'),
                  Colors.red,
                  icon: Icons.close,
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
      child: _actionButton(
        "Cancel Booking", 
        _cancelBooking, 
        Colors.orange,
        icon: Icons.cancel,
      ),
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
              style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _clickableInfoRow(String label, String value) {
    return InkWell(
      onTap: () => _openGoogleMaps(value),
      child: Padding(
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
              child: Row(
                children: [
                  Icon(
                    Icons.location_on, 
                    size: 16, 
                    color: _accentColor,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 14, 
                        color: _accentColor, 
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
      border: Border.all(
        color: _primaryColor.withOpacity(0.1),
        width: 1,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: _primaryColor, width: 2),
      ),
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade500),
      prefixIcon: Icon(icon, color: _accentColor),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }

  Widget _actionButton(
    String text, 
    VoidCallback onPressed, 
    Color color, 
    {IconData? icon}
  ) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isUpdating ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
          shadowColor: color.withOpacity(0.5),
        ),
        child: _isUpdating
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  TextStyle _labelStyle() => TextStyle(
        fontWeight: FontWeight.bold,
        color: _primaryColor,
        fontSize: 14,
      );

  Widget _sectionTitle(String title) => Row(
        children: [
          Container(
            height: 18,
            width: 4,
            decoration: BoxDecoration(
              color: _primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _darkPurple,
            ),
          ),
        ],
      );

  Widget _titleRow(String title, String status) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _darkPurple,
            ),
          ),
          _statusBadge(status),
        ],
      );

  Widget _statusBadge(String status) {
    Color badgeColor;
    IconData statusIcon;
    
    switch (status) {
      case 'Accepted':
        badgeColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'Rejected':
        badgeColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'Completed':
        badgeColor = Colors.blue;
        statusIcon = Icons.task_alt;
        break;
      default:
        badgeColor = _primaryColor;
        statusIcon = Icons.schedule;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: badgeColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 14, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: badgeColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    _vendorNameController.dispose();
    _vendorPhoneController.dispose();
    super.dispose();
  }
}