import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final Color primaryColor;
  final Color accentColor;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today), label: 'Bookings'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      currentIndex: selectedIndex,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
      onTap: onItemTapped,
    );
  }
}
