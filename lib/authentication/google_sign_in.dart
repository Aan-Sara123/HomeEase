import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

class GoogleSignInService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn();
  static final Logger _logger = Logger(); // Initialize Logger instance

  /// Signs in a user with Google
  static Future<User?> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        _logger.i('Google Sign-In canceled by the user.');
        return null;
      }

      // Obtain the Google Sign-In authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new Firebase credential with Google tokens
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase using the Google credential
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      _logger.i('Google Sign-In successful for user: ${userCredential.user?.email}');
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      _logger.e('FirebaseAuthException during Google Sign-In: ${e.message}');
      return null;
    } catch (e) {
      _logger.e('Exception during Google Sign-In: $e');
      return null;
    }
  }

  /// Signs out the user from both Google and Firebase
  static Future<void> signOutFromGoogle() async {
    try {
      await _googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();
      _logger.i('User signed out from Google and Firebase.');
    } catch (e) {
      _logger.e('Error during Google Sign-Out: $e');
    }
  }

  /// Disconnects the Google account from the app (useful if you want to clear the session)
  static Future<void> disconnectFromGoogle() async {
    try {
      await _googleSignIn.disconnect();
      _logger.i('Google account disconnected successfully.');
    } catch (e) {
      _logger.e('Error during Google Disconnect: $e');
    }
  }
}
