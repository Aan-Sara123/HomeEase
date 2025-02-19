import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this for date formatting
import 'firebase_service.dart'; // Import FirebaseService


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

  // Method to select a date using DatePicker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Method to select a time using TimePicker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // Method to confirm the booking and save it
  void _confirmBooking() {
    if (_selectedDate != null && _selectedTime != null) {
      // Format the date and time
      String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      String formattedTime = _selectedTime!.format(context);

      // Save the booking to Firebase
      _firebaseService.saveBooking(
          widget.serviceName, formattedDate, formattedTime);

      // Show confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Booking confirmed for $formattedDate at $formattedTime'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Optionally, navigate back or clear fields
    } else {
      // Show error if date or time isn't selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both date and time'),
          backgroundColor: Colors.red,
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
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Schedule your ${widget.serviceName} service',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            // Date picker
            TextField(
              decoration: InputDecoration(
                labelText: 'Select Date',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              readOnly: true,
              onTap: () => _selectDate(context),
              controller: TextEditingController(
                  text: _selectedDate == null
                      ? 'No Date Chosen'
                      : DateFormat('yyyy-MM-dd').format(_selectedDate!)),
            ),
            const SizedBox(height: 16),
            // Time picker
            TextField(
              decoration: InputDecoration(
                labelText: 'Select Time',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              readOnly: true,
              onTap: () => _selectTime(context),
              controller: TextEditingController(
                  text: _selectedTime == null
                      ? 'No Time Chosen'
                      : _selectedTime!.format(context)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _confirmBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF673AB7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: const Center(child: Text('Confirm Booking')),
            ),
          ],
        ),
      ),
    );
  }
}
