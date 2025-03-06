// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Define color palette
    const Color primaryPurple = Color(0xFF6A1B9A);
    const Color lightPurple = Color(0xFF9C27B0);
    const Color darkPurple = Color(0xFF4A148C);
    const Color accentPurple = Color(0xFFAB47BC);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: darkPurple,
        centerTitle: true,
        elevation: 4,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF3E5F5), Colors.white],
            stops: [0.3, 1.0],
          ),
        ),
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(20),
            elevation: 8,
            shadowColor: primaryPurple.withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(color: accentPurple.withOpacity(0.5), width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.home_repair_service,
                    size: 60,
                    color: primaryPurple,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Welcome to HomeEase Services!',
                    style: TextStyle(
                      fontSize: 22, 
                      fontWeight: FontWeight.bold, 
                      color: primaryPurple,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Your one-stop solution for all home services',
                    style: TextStyle(
                      fontSize: 16,
                      color: primaryPurple.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to available services list
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lightPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 5,
                      shadowColor: darkPurple.withOpacity(0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.list_alt, color: Colors.white),
                        SizedBox(width: 10),
                        Text('View Services', style: TextStyle(fontSize: 18, color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}