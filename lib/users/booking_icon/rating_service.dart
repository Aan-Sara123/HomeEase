// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RatingService {
  static void showRatingDialog(BuildContext context, String bookingId) {
    double rating = 3.0; // Default rating
    
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          backgroundColor: Colors.white,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Color(0xFFF3E5F5), // Very light purple
                ],
              ),
            ),
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF673AB7).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.star,
                            color: Color(0xFF673AB7),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Rate Service",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A148C), // Deep purple
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Rating text
                    const Text(
                      "Please rate the service",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF673AB7), // Purple
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Star display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: const Color(0xFFAA00FF), // Purple accent
                          size: 36,
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    
                    // Slider
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: const Color(0xFF9C27B0),
                        inactiveTrackColor: const Color(0xFFE1BEE7),
                        thumbColor: const Color(0xFF7B1FA2),
                        overlayColor: const Color(0xFF9C27B0).withOpacity(0.2),
                        valueIndicatorColor: const Color(0xFF7B1FA2),
                        valueIndicatorTextStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        trackHeight: 6,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
                      ),
                      child: Slider(
                        value: rating,
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: rating.toString(),
                        onChanged: (value) {
                          setState(() {
                            rating = value;
                          });
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Rating label
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1C4E9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getRatingLabel(rating),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A148C),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Cancel Button
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF9575CD),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        
                        // Submit Button
                        ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context); // Close dialog first
                            await submitRating(bookingId, rating, context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF673AB7),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check, size: 20),
                              SizedBox(width: 8),
                              Text(
                                "Submit",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Helper function to get rating label
  static String _getRatingLabel(double rating) {
    if (rating >= 4.5) return "Excellent!";
    if (rating >= 3.5) return "Very Good";
    if (rating >= 2.5) return "Good";
    if (rating >= 1.5) return "Fair";
    return "Poor";
  }

  static Future<void> submitRating(String bookingId, double rating, BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({'rating': rating});
      debugPrint("Rating submitted: $rating for booking: $bookingId");
      
      if (!context.mounted) return; // Check if context is still valid
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text("Thank you! Rating submitted: $rating"),
            ],
          ),
          backgroundColor: const Color(0xFF673AB7),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      debugPrint("Error submitting rating: $e");
      
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Text("Failed to submit rating. Please try again."),
            ],
          ),
          backgroundColor: const Color(0xFFC2185B), // Dark pink for error
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}