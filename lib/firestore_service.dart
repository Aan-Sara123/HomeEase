import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getUserByNameAndPhone(String name, String phone) async {
    final querySnapshot = await _db
        .collection('users')
        .where('name', isEqualTo: name)
        .where('phoneNumber', isEqualTo: phone)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.data();
    } else {
      return null;
    }
  }

  Future<void> addUser(Map<String, dynamic> userData) async {
    await _db.collection('users').add(userData);
  }
   Future<void> addVendor(Map<String, dynamic> vendorData) async {
    await _db.collection('vendors').add(vendorData);
  }
}
