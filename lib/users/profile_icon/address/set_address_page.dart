import 'package:flutter/material.dart';
import 'address_service.dart';
import 'package:geolocator/geolocator.dart';
import 'address_styles.dart'; // Import the new styles file

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
  final AddressStyles styles = AddressStyles(); // Use the style class

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
          backgroundColor: styles.primaryColor,
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
      backgroundColor: styles.backgroundColor,
      appBar: AppBar(
        title: Text('Set Address', style: styles.appBarTitleStyle),
        backgroundColor: styles.primaryColor,
        elevation: 4,
        centerTitle: true,
        shape: styles.appBarShape,
      ),
      body: Container(
        decoration: styles.pageBackgroundDecoration,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: _isLoading
                ? Container(
                    padding: const EdgeInsets.all(20),
                    decoration: styles.loadingContainerDecoration,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(styles.primaryColor),
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_currentPosition != null)
                        Card(
                          elevation: 8,
                          shape: styles.cardShape,
                          child: Container(
                            decoration: styles.cardDecoration,
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
                                    style: styles.addressTextStyle,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 40),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.location_pin, size: 24),
                        label: Text('GET CURRENT LOCATION',
                            style: styles.buttonTextStyle),
                        onPressed: _fetchAndSaveLocation,
                        style: styles.locationButtonStyle,
                      ),
                    ],
                  ),
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
          style: styles.locationLabelStyle,
        ),
        Text(
          value,
          style: styles.locationValueStyle,
        ),
      ],
    );
  }
}