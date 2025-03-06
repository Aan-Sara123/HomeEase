import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getVendorByNameAndPhone(String name, String phone) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('vendors')
          .where('name', isEqualTo: name)
          .where('phoneNumber', isEqualTo: phone) // Fixed field name
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      throw Exception("Error fetching vendor: $e");
    }
  }
}
