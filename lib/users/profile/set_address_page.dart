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
  final Color _primaryTeal = const Color(0xFF00796B);
  final Color _lightTeal = const Color(0xFFE0F2F1);

  Future<void> _fetchAndSaveLocation() async {
    setState(() => _isLoading = true);

    try {
      final Position? position = await _addressService.getCurrentLocation();
      if (position == null) throw Exception('Location service failed');

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
        SnackBar(
          content: Text('Location Saved: ${address ?? "Unknown"}'),
          backgroundColor: _primaryTeal,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightTeal,
      appBar: AppBar(
        title: const Text('Set Address', style: TextStyle(letterSpacing: 1.2)),
        backgroundColor: _primaryTeal,
        elevation: 4,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: _isLoading
              ? Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.3),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(_primaryTeal),
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_currentPosition != null)
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              _buildLocationRow(
                                  'Latitude:',
                                  _currentPosition!.latitude
                                      .toStringAsFixed(5)),
                              const SizedBox(height: 12),
                              _buildLocationRow(
                                  'Longitude:',
                                  _currentPosition!.longitude
                                      .toStringAsFixed(5)),
                              const SizedBox(height: 20),
                              if (_address != null)
                                Text(
                                  _address!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 40),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.location_pin, size: 24),
                      label: const Text('GET CURRENT LOCATION',
                          style: TextStyle(letterSpacing: 1.1)),
                      onPressed: _fetchAndSaveLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryTeal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        shadowColor: Colors.green[800],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildLocationRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _primaryTeal,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'RobotoMono',
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
