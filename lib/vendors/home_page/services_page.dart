// ignore_for_file: unused_local_variable, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'booking_details_page.dart';
import 'contact_admin.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  String? vendorExpertise;
  String? vendorId;

  @override
  void initState() {
    super.initState();
    _fetchVendorExpertise();
  }

  Future<void> _fetchVendorExpertise() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot vendorSnapshot =
        await FirebaseFirestore.instance.collection('vendors').doc(uid).get();

    if (vendorSnapshot.exists) {
      setState(() {
        vendorExpertise = vendorSnapshot['expertise'];
        vendorId = uid; // ✅ Capture vendorId here
      });
    }
  }

  Stream<QuerySnapshot> _getRelevantBookings() {
    if (vendorExpertise == null) {
      return const Stream.empty();
    }
    return FirebaseFirestore.instance
        .collection('bookings')
        .where('serviceName', isEqualTo: vendorExpertise)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFF6A1B9A);
    const accentPurple = Color(0xFF9C27B0);
    const lightPurple = Color(0xFFE1BEE7);
    const darkPurple = Color(0xFF4A148C);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Service Requests',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryPurple,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: vendorExpertise == null
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(accentPurple),
                    ),
                  )
                : StreamBuilder<QuerySnapshot>(
                    stream: _getRelevantBookings(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(accentPurple),
                          ),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_busy,
                                size: 80,
                                color: accentPurple.withOpacity(0.6),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No bookings available',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: darkPurple,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      var bookings = snapshot.data!.docs;

                      return ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: bookings.length,
                        itemBuilder: (context, index) {
                          var bookingDoc = bookings[index];
                          var booking = bookingDoc.data() as Map<String, dynamic>;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: const Icon(Icons.miscellaneous_services, color: darkPurple),
                                title: Text(
                                  'Service: ${booking['serviceName']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Date: ${booking['date']}'),
                                    Text('Time: ${booking['time']}'),
                                  ],
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BookingDetailsPage(
                                        bookingId: bookingDoc.id,
                                        bookingData: booking,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
          // Contact Us Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentPurple,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.contact_mail, color: Colors.white),
              label: const Text(
                'Contact Admin',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onPressed: vendorId == null
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ContactAdminPage(
                            vendorId: vendorId!, // ✅ Pass vendorId here
                          ),
                        ),
                      );
                    },
            ),
          ),
        ],
      ),
    );
  }
}
