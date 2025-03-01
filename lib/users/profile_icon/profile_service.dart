import 'dart:io';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<Map<String, dynamic>?> getUserProfile() async {
    final User? user = _auth.currentUser;
    if (user == null) return null;

    try {
      final DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      log("Error fetching profile: $e");
    }
    return null;
  }

  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return null;

      final ref = _storage.ref().child('profile_images/${user.uid}.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      log("Error uploading image: $e");
      return null;
    }
  }

  Future<void> saveUserProfile(
      String name, String phone, String? imageUrl) async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'name': name.trim(),
        'phone': phone.trim(),
        'photoUrl': imageUrl ?? "",
      }, SetOptions(merge: true));
    } catch (e) {
      log("Error saving profile: $e");
    }
  }
}
