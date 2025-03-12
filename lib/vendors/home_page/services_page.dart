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
    // Enhanced color palette
    const primaryPurple = Color(0xFF6A1B9A);
    const accentPurple = Color(0xFF9C27B0);
    const lightPurple = Color(0xFFE1BEE7);
    const darkPurple = Color(0xFF4A148C);
    const backgroundPurple = Color(0xFFF3E5F5);
    const highlightPurple = Color(0xFFBA68C8);
    
    // Text styles
    const headingStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 20,
      color: Colors.white,
    );
    
    const cardTitleStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
      color: darkPurple,
    );
    
    const cardSubtitleStyle = TextStyle(
      fontSize: 14,
      color: Colors.black87,
    );

    return Scaffold(
      backgroundColor: backgroundPurple,
      appBar: AppBar(
        title: const Text(
          'Your Service Requests',
          style: headingStyle,
        ),
        centerTitle: true,
        backgroundColor: primaryPurple,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => setState(() {}),
            tooltip: 'Refresh Bookings',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [backgroundPurple, Colors.white],
            stops: [0.0, 0.7],
          ),
        ),
        child: Column(
          children: [
            // Quote container at the top
            Container(
              margin: const EdgeInsets.fromLTRB(16, 20, 16, 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: primaryPurple.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    '"Excellence in service is not an act but a habit"',
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: darkPurple,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '— Professional Services',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.purple[300],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            // Status info banner
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: lightPurple.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: accentPurple.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: darkPurple),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      vendorExpertise != null
                          ? 'Showing requests for your expertise: $vendorExpertise'
                          : 'Loading your expertise area...',
                      style: const TextStyle(
                        color: darkPurple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Bookings list
            Expanded(
              child: vendorExpertise == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(accentPurple),
                            strokeWidth: 3,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Loading your service requests...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.purple[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : StreamBuilder<QuerySnapshot>(
                      stream: _getRelevantBookings(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(accentPurple),
                              strokeWidth: 3,
                            ),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: lightPurple.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.event_busy,
                                    size: 70,
                                    color: accentPurple.withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'No Service Requests Available',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: darkPurple,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 32),
                                  child: Text(
                                    'New requests matching your expertise will appear here',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.purple[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        var bookings = snapshot.data!.docs;

                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: ListView.builder(
                            padding: const EdgeInsets.only(top: 8, bottom: 16),
                            itemCount: bookings.length,
                            itemBuilder: (context, index) {
                              var bookingDoc = bookings[index];
                              var booking = bookingDoc.data() as Map<String, dynamic>;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Card(
                                  elevation: 4,
                                  shadowColor: primaryPurple.withOpacity(0.3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    splashColor: lightPurple,
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
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: lightPurple,
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  color: lightPurple.withOpacity(0.3),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: const Icon(
                                                  Icons.miscellaneous_services,
                                                  color: darkPurple,
                                                  size: 28,
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Service: ${booking['serviceName']}',
                                                      style: cardTitleStyle,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      'Request #${bookingDoc.id.substring(0, 6)}',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: highlightPurple.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: const Text(
                                                  'New',
                                                  style: TextStyle(
                                                    color: darkPurple,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          const Divider(height: 1, thickness: 1, color: lightPurple),
                                          const SizedBox(height: 16),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.calendar_today,
                                                        size: 16,
                                                        color: accentPurple,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        'Date: ${booking['date']}',
                                                        style: cardSubtitleStyle,
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.access_time,
                                                        size: 16,
                                                        color: accentPurple,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        'Time: ${booking['time']}',
                                                        style: cardSubtitleStyle,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
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
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: accentPurple,
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 10,
                                                  ),
                                                ),
                                                child: const Text(
                                                  'View Details',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
            
            // Contact Admin Button
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: darkPurple.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
                gradient: const LinearGradient(
                  colors: [primaryPurple, darkPurple],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.contact_mail, color: Colors.white),
                label: const Text(
                  'Contact Admin Support',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
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
      ),
    );
  }
}