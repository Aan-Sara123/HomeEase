import 'package:flutter/material.dart';

class CustomSearchDelegate extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = ''; // Clear the search field
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null); // Close the search delegate
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: Text(
        'You searched for "$query"',
        style: const TextStyle(fontSize: 18),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(
      child: Text(
        'Search for services...',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}
