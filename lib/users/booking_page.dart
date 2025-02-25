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
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
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
    if (_selectedDate != null && _selectedTime != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      String formattedTime = _selectedTime!.format(context);

      // 🔥 Get the current user's ID from Firebase Auth
      User? user = FirebaseAuth.instance.currentUser;
      String userId = user?.uid ?? "Unknown User";

      // 🔥 Get the FCM token
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠ Failed to get FCM token. Please check notification permissions.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      try {
        await _firebaseService.saveBooking(
          userId,
          widget.serviceName,
          formattedDate,
          formattedTime,
          fcmToken,
        );
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Booking confirmed for $formattedDate at $formattedTime'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error confirming booking: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠ Please select both date and time'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.serviceName} Booking'),
        backgroundColor: const Color(0xFF673AB7),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: 'Select Date',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _timeController,
              decoration: const InputDecoration(
                labelText: 'Select Time',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              onTap: () => _selectTime(context),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _confirmBooking,
              child: const Text('Confirm Booking'),
            ),
          ],
        ),
      ),
    );
  }
}
