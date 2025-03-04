// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class AddressStyles {
  // Main colors
  final Color primaryColor = const Color(0xFF673AB7); // Deep Purple
  final Color secondaryColor = const Color(0xFFD1C4E9); // Light Purple
  final Color accentColor = const Color(0xFF9575CD); // Medium Purple
  final Color backgroundColor = const Color(0xFFF3E5F5); // Very Light Purple

  // Text colors
  final Color primaryTextColor = const Color(0xFF212121);
  final Color secondaryTextColor = const Color(0xFF757575);

  // Gradients
  LinearGradient get primaryGradient => const LinearGradient(
        colors: [Color(0xFF673AB7), Color(0xFF5E35B1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  LinearGradient get cardGradient => const LinearGradient(
        colors: [Colors.white, Color(0xFFF5F0FF)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  // Shadows
  List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: primaryColor.withOpacity(0.2),
          blurRadius: 10,
          offset: const Offset(0, 4),
          spreadRadius: 1,
        ),
      ];

  // Text styles
  TextStyle get appBarTitleStyle => const TextStyle(
        letterSpacing: 1.2,
        fontWeight: FontWeight.w600,
        fontSize: 20,
      );

  TextStyle get locationLabelStyle => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: primaryColor,
        letterSpacing: 0.5,
      );

  TextStyle get locationValueStyle => TextStyle(
        fontSize: 16,
        fontFamily: 'RobotoMono',
        color: primaryTextColor,
        fontWeight: FontWeight.w500,
      );

  TextStyle get addressTextStyle => TextStyle(
        fontSize: 16,
        color: secondaryTextColor,
        fontStyle: FontStyle.italic,
        letterSpacing: 0.3,
        height: 1.4,
      );

  TextStyle get buttonTextStyle => const TextStyle(
        letterSpacing: 1.1,
        fontWeight: FontWeight.w600,
        fontSize: 15,
      );

  // Shapes
  RoundedRectangleBorder get appBarShape => const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      );

  RoundedRectangleBorder get cardShape => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      );

  // Button styles
  ButtonStyle get locationButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 6,
        shadowColor: primaryColor.withOpacity(0.5),
      );

  // Container decorations
  BoxDecoration get loadingContainerDecoration => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      );

  BoxDecoration get cardDecoration => BoxDecoration(
        gradient: cardGradient,
        borderRadius: BorderRadius.circular(16),
      );

  BoxDecoration get pageBackgroundDecoration => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            backgroundColor,
            backgroundColor.withOpacity(0.85),
          ],
        ),
      );
}
