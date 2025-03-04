// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class ContactUsStyles {
  static const Color primaryColor = Color(0xFF673AB7);
  static const Color accentColor = Color(0xFF512DA8);
  static const Color backgroundColor = Colors.white;
  static const Color textColor = Color(0xFF333333);

  static TextStyle sectionTitleStyle = const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: primaryColor,
    letterSpacing: 0.5,
  );

  static TextStyle contactInfoStyle = const TextStyle(
    fontSize: 16,
    color: textColor,
    height: 1.5,
  );

  static InputDecoration inputDecoration(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: primaryColor),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD1C4E9)),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      );

  static ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    elevation: 4,
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  );

  static BoxDecoration contactCardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.1),
        spreadRadius: 3,
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );
}