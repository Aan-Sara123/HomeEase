import 'package:flutter/material.dart';
import 'address_service.dart';
import 'package:geolocator/geolocator.dart';

class SetAddressPage extends StatefulWidget {
  const SetAddressPage({super.key});

  @override
  State<SetAddressPage> createState() => _SetAddressPageState();
}

class _SetAddressPageState extends State<SetAddressPage> {
  final AddressService _addressService = AddressService();
  bool _isLoading = false;
  Position? _currentPosition;
  String? _address;

  Future<void> _fetchAndSaveLocation() async {
    setState(() => _isLoading = true);

    final Position? position = await _addressService.getCurrentLocation();
    if (position != null) {
      final String? address = await _addressService.getAddressFromCoordinates(
          position.latitude, position.longitude);

      await _addressService.saveAddress(
          position.latitude, position.longitude, address);

      if (!mounted) return;

      setState(() {
        _currentPosition = position;
        _address = address;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location Saved: ${address ?? "Unknown"}')),
      );
    } else {
      if (!mounted) return;

      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to get location.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Address'),
        backgroundColor: const Color(0xFF673AB7),
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_currentPosition != null)
                    Column(
                      children: [
                        Text(
                          "Latitude: ${_currentPosition!.latitude}",
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          "Longitude: ${_currentPosition!.longitude}",
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        if (_address != null)
                          Text(
                            "Address: $_address",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _fetchAndSaveLocation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF673AB7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Set Address',
                        style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
      ),
    );
  }
}
