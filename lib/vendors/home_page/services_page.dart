import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'booking_details_page.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  String? vendorExpertise;

  @override
  void initState() {
    super.initState();
    _fetchVendorExpertise();
  }

  /// Fetches the logged-in vendor's expertise from Firestore
  Future<void> _fetchVendorExpertise() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot vendorSnapshot =
        await FirebaseFirestore.instance.collection('vendors').doc(uid).get();

    if (vendorSnapshot.exists) {
      setState(() {
        vendorExpertise = vendorSnapshot['expertise'];
      });
    }
  }

  /// Fetches bookings that match the vendor's expertise
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Service Requests'),
        centerTitle: true,
        backgroundColor: Colors.purple,
      ),
      body: vendorExpertise == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: _getRelevantBookings(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No bookings available.'));
                }

                var bookings = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    var bookingDoc = bookings[index];
                    var booking = bookingDoc.data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text('Service: ${booking['serviceName']}'),
                        subtitle: Text('Date: ${booking['date']} \nTime: ${booking['time']}'),
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
                    );
                  },
                );
              },
            ),
    );
  }
}
