import 'package:flutter/material.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Services'),
        backgroundColor: Colors.teal,
      ),
      body: const Center(
        child: Text(
          'Here are the available services for users.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
