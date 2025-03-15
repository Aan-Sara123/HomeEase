// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'users/registration/user_registration.dart';
import 'users/services_page.dart';
import 'vendors/registration/registration_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'HomeEase',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: const Color(0xFF673AB7), 
        foregroundColor: Colors.white,// Deep Purple
        elevation: 0, // Remove shadow for modern look
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF673AB7), // Deep Purple
              Color(0xFF9C27B0), // Purple
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Welcome to HomeEase!',
                  style: TextStyle(
                    fontSize: 28, // Slightly larger
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5, // Improve readability
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Text(
                    'Your go-to platform for connecting homeowners and service providers. Are you a User or a Vendor?',
                    style: TextStyle(
                      fontSize: 16, 
                      color: Colors.white,
                      height: 1.4, // Improves line spacing
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 50), // Increased spacing
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF673AB7), // Deep Purple
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 40), // Larger button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5, // Add shadow
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserRegistration(),
                      ),
                    );
                  },
                  child: const Text(
                    'Register as a User',
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 25), // Increased spacing
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.9), // Slightly transparent
                    foregroundColor: const Color(0xFF673AB7), // Deep Purple
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 40), // Larger button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5, // Add shadow
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VendorRegistrationPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Register as a Vendor',
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}