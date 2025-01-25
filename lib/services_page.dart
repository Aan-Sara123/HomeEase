import 'package:flutter/material.dart';
import 'package:homeeaseapp/custom_search_delegate.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Services'),
        backgroundColor: const Color.fromARGB(255, 202, 154, 114),
       actions: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  showSearch(
                    context: context,
                    delegate: CustomSearchDelegate(),
                  ); // Handle search action here
                },
              ),
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  // Handle add to cart action here
                },
              ),
            ],
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Here are the available services for users.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}