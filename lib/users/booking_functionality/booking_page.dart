import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_service.dart';

class BookingPage extends StatefulWidget {
  final String serviceName;
  const BookingPage({super.key, required this.serviceName});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final FirebaseService _firebaseService = FirebaseService();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _bookingId;

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  Future<void> _confirmBooking() async {
    if (_selectedDate != null && _selectedTime != null && _addressController.text.isNotEmpty) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      String formattedTime = _selectedTime!.format(context);
      String address = _addressController.text.trim();

      User? user = FirebaseAuth.instance.currentUser;
      String userId = user?.uid ?? "Unknown User";

      String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠ Failed to get FCM token.')),
        );
        return;
      }

      try {
        String bookingId = await _firebaseService.saveBooking(
          userId, widget.serviceName, formattedDate, formattedTime, address, fcmToken,
        );

        setState(() {
          _bookingId = bookingId;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Booking confirmed for $formattedDate at $formattedTime')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error confirming booking: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠ Please select date, time, and enter address')),
      );
    }
  }

  Future<void> _cancelBooking() async {
    if (_bookingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠ No booking to cancel.')),
      );
      return;
    }

    try {
      await _firebaseService.cancelBooking(_bookingId!);
      setState(() {
        _bookingId = null;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Booking canceled successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error canceling booking: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.serviceName} Booking'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildTextField(_dateController, 'Select Date', Icons.calendar_today, () => _selectDate(context)),
            const SizedBox(height: 10),
            _buildTextField(_timeController, 'Select Time', Icons.access_time, () => _selectTime(context)),
            const SizedBox(height: 10),
            _buildTextField(_addressController, 'Enter Address', Icons.location_on, null, isReadOnly: false),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _confirmBooking,
              child: const Text('Confirm Booking'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _cancelBooking,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Cancel Booking'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, VoidCallback? onTap, {bool isReadOnly = true}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(),
      ),
      readOnly: isReadOnly,
      onTap: onTap,
    );
  }
}
