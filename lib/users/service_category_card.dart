import 'package:flutter/material.dart';

class ServiceCategoryCard extends StatelessWidget {
  final Map<String, String> service;
  const ServiceCategoryCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(service['image']!, fit: BoxFit.cover)),
          ),
          const SizedBox(height: 8),
          Text(service['name']!,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87),
              textAlign: TextAlign.center,
              maxLines: 2),
        ],
      ),
    );
  }
}
