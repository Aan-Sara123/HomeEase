import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _confirmBooking() async {
    if (_selectedDate != null && _selectedTime != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      String formattedTime = _selectedTime!.format(context);

      try {
        await _firebaseService.saveBooking(widget.serviceName, formattedDate, formattedTime);
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
              decoration: InputDecoration(
                labelText: 'Select Date',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              onTap: () => _selectDate(context),
              controller: TextEditingController(
                text: _selectedDate == null ? 'No Date Chosen' : DateFormat('yyyy-MM-dd').format(_selectedDate!),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Select Time',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              onTap: () => _selectTime(context),
              controller: TextEditingController(
                text: _selectedTime == null ? 'No Time Chosen' : _selectedTime!.format(context),
              ),
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
