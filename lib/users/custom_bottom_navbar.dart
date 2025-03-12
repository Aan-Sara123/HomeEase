// ignore_for_file: deprecated_member_use

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
    // Define a consistent purple color palette
    final deepPurple = primaryColor;
    final lightPurple = accentColor;
    final purpleGrey = Colors.grey.shade600;
    
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: deepPurple.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selectedIndex == 0 
                      ? lightPurple.withOpacity(0.2) 
                      : Colors.transparent,
                ),
                child: const Icon(Icons.home_rounded),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selectedIndex == 1 
                      ? lightPurple.withOpacity(0.2) 
                      : Colors.transparent,
                ),
                child: const Icon(Icons.calendar_today_rounded),
              ),
              label: 'Bookings',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selectedIndex == 2 
                      ? lightPurple.withOpacity(0.2) 
                      : Colors.transparent,
                ),
                child: const Icon(Icons.person_rounded),
              ),
              label: 'Profile',
            ),
          ],
          elevation: 15,
          backgroundColor: Colors.white,
          currentIndex: selectedIndex,
          selectedItemColor: deepPurple,
          unselectedItemColor: purpleGrey,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          onTap: onItemTapped,
        ),
      ),
    );
  }
}