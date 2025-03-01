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

class _ServicesPageState extends State<ServicesPage> {
  int _selectedIndex = 0;
  final Color _primaryColor = const Color(0xFF673AB7);
  final Color _accentColor = const Color.fromARGB(255, 215, 200, 209);

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
        title: const Text('Available Services', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: _primaryColor,
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: _accentColor),
            onPressed: () => showSearch(context: context, delegate: CustomSearchDelegate()),
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart, color: _accentColor),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Text('Service Categories', style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _primaryColor,
                )),
          ),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: services.length,
              itemBuilder: (context, index) => ServiceCategoryCard(service: services[index]),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9,
                ),
                itemCount: services.length,
                itemBuilder: (context, index) => ServiceGridCard(service: services[index]),
              ),
            ),
          ),
        ],
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
