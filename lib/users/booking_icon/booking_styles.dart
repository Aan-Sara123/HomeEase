// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class BookingStyles {
  // Primary color and shades
  static const Color primaryColor = Color(0xFF673AB7);
  static const Color primaryLight = Color(0xFFD1C4E9);
  static const Color primaryDark = Color(0xFF512DA8);

  // Background gradient
  static final Gradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    // ignore: duplicate_ignore
    // ignore: deprecated_member_use
    colors: [primaryLight.withOpacity(0.1), primaryLight.withOpacity(0.3)],
  );

  // App bar title style
  static const TextStyle appBarTitleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 1.2,
  );

  // Loading text style
  static final TextStyle loadingTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: primaryDark,
  );

  // Error icon and text styles
  static final Color errorIconColor = primaryDark;
  static final TextStyle errorTextStyle = TextStyle(
    fontSize: 16,
    color: primaryDark,
    fontWeight: FontWeight.w500,
  );

  // Empty state icon and text styles
  static final Color emptyIconColor = primaryLight;
  static final TextStyle emptyTextStyle = TextStyle(
    fontSize: 18,
    color: primaryDark,
    fontWeight: FontWeight.w500,
  );

  // Booking card styles
  static const TextStyle serviceNameStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: primaryDark,
  );

  static const TextStyle statusTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.8,
  );

  // Detail row styles
  static final Color detailIconColor = primaryDark.withOpacity(0.8);
  static final TextStyle detailTextStyle = TextStyle(
    fontSize: 14,
    color: primaryDark,
  );
  static final TextStyle detailLabelStyle = TextStyle(
    fontWeight: FontWeight.w500,
    color: primaryDark,
  );
  static final TextStyle detailValueStyle = TextStyle(
    color: primaryDark.withOpacity(0.8),
  );

  // Status color mapping
  static Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'confirmed':
        return Colors.green.shade600;
      case 'pending':
        return Colors.orange.shade600;
      case 'cancelled':
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }
}