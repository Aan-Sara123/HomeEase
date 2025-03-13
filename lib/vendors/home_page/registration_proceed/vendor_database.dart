import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VendorDatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> registerVendor(String name, String address, String expertise, int experience, String phone, String email, String? certificate) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    
    await _firestore.collection('vendors').doc(uid).set({
      'name': name,
      'address': address,
      'expertise': expertise,
      'experience': experience,
      'phone': phone,
      'email': email,
      'certificate': certificate ?? '',
      'status': 'pending', // Default status
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<DocumentSnapshot> getVendorStatus() {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    return _firestore.collection('vendors').doc(uid).snapshots();
  }
}