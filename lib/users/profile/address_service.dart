import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:developer';

class AddressService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches the current location of the user
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      log("Location services are disabled.");
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        log("Location permission denied.");
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      log("Location permissions are permanently denied.");
      return null;
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  /// Converts latitude & longitude into an address
  Future<String?> getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        String address =
            "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";

        log("Address: $address");
        return address;
      } else {
        return "Address not found";
      }
    } catch (e) {
      log("Error fetching address: $e");
      return null;
    }
  }

  /// Saves the address to Firestore
  Future<void> saveAddress(
      double latitude, double longitude, String? address) async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'address': {
          'latitude': latitude,
          'longitude': longitude,
          'full_address': address,
        }
      }, SetOptions(merge: true));

      log("Address saved: $address ($latitude, $longitude)");
    } catch (e) {
      log("Error saving address: $e");
    }
  }
}
