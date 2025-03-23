import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static bool isAdmin() {
    // Replace with actual admin check
    return FirebaseAuth.instance.currentUser?.email == "admin@homeease.com";
  }
}
