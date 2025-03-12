// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'profile_icon/profile_page.dart';
import 'service_category_card.dart';
import 'booking_functionality/service_grid_card.dart';
import 'custom_bottom_navbar.dart';
import 'custom_search_delegate.dart';
import 'service.dart';
import 'booking_icon/booking_details_page.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  // Enhanced color palette
  final Color _primaryColor = const Color(0xFF673AB7);
  final Color _accentColor = const Color(0xFFD1C4E9);
  final Color _darkPurple = const Color(0xFF4527A0);
  final Color _lightPurple = const Color(0xFFEDE7F6);
  final Color _purpleAccent = const Color(0xFF7C4DFF);

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      Widget? destination;
      if (_selectedIndex == 0) {
        destination = const ServicesPage();
      } else if (_selectedIndex == 1) {
        destination = const BookingDetailsPage();
      } else if (_selectedIndex == 2) {
        destination = const ProfilePage();
      }

      if (destination != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination!),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Services',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            fontSize: 20,
          ),
        ),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_lightPurple, Colors.white],
            stops: const [0.0, 0.3],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Icon(Icons.category_rounded, color: _primaryColor, size: 22),
                    const SizedBox(width: 8),
                    Text('Service Categories',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _primaryColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 130,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ServiceCategoryCard(service: services[index]),
                    );
                  },
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      return ServiceGridCard(service: services[index]);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        primaryColor: _primaryColor,
        accentColor: _accentColor,
      ),
    );
  }
}
