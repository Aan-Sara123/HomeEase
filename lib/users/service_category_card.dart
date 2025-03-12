// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class ServiceCategoryCard extends StatelessWidget {
  final Map<String, String> service;
  const ServiceCategoryCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    // Define our purple color palette
    const Color deepPurple = Color(0xFF6A1B9A);
    const Color lightPurple = Color(0xFFE1BEE7);
    
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: deepPurple.withOpacity(0.15),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(
                color: lightPurple.withOpacity(0.7),
                width: 1.5,
              ),
            ),
            child: Stack(
              children: [
                // The image
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    service['image']!,
                    fit: BoxFit.cover,
                    height: 70,
                    width: 70,
                  ),
                ),
                // Subtle purple gradient overlay
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        deepPurple.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              service['name']!,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: deepPurple,
                letterSpacing: 0.3,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}