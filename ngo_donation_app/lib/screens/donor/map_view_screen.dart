import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({Key? key}) : super(key: key);

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  final Set<Marker> _markers = {};
  bool _isLoading = true;

  static const LatLng _defaultLocation = LatLng(19.0760, 72.8777); // Mumbai

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await _loadNGOs(_defaultLocation.latitude, _defaultLocation.longitude);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        await _loadNGOs(_defaultLocation.latitude, _defaultLocation.longitude);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() => _currentPosition = position);

      await _loadNGOs(position.latitude, position.longitude);
    } catch (e) {
      await _loadNGOs(_defaultLocation.latitude, _defaultLocation.longitude);
    }
  }

  Future<void> _loadNGOs(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse(
            "http://YOUR_BACKEND_IP:5000/api/map?latitude=$lat&longitude=$lon&maxDistance=50000"),
      );

      final data = json.decode(response.body);
      final ngos = data['data'] ?? [];

      Set<Marker> markers = {};

      // Current location marker
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(lat, lon),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: "Your Location"),
        ),
      );

      // NGO markers
      for (var ngo in ngos) {
        final location = ngo['location'];
        if (location != null &&
            location['coordinates'] != null &&
            location['coordinates'].length >= 2) {
          final coords = location['coordinates'];

          markers.add(
            Marker(
              markerId: MarkerId(ngo['_id'].toString()),
              position: LatLng(coords[1], coords[0]), // [lng, lat]
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed),
              infoWindow: InfoWindow(
                title: ngo['name'] ?? 'NGO',
                snippet: ngo['area'] ?? '',
              ),
            ),
          );
        }
      }

      setState(() {
        _markers.clear();
        _markers.addAll(markers);
        _isLoading = false;
      });

      // Move camera
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(lat, lon),
          12,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    LatLng startPosition = _currentPosition != null
        ? LatLng(_currentPosition!.latitude,
            _currentPosition!.longitude)
        : _defaultLocation;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nearby NGOs"),
        backgroundColor: const Color(0xFF6200EE),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: startPosition,
                zoom: 12,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              markers: _markers,
              onMapCreated: (controller) {
                _mapController = controller;
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6200EE),
        child: const Icon(Icons.my_location),
        onPressed: () {
          if (_currentPosition != null) {
            _mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(
                LatLng(_currentPosition!.latitude,
                    _currentPosition!.longitude),
                14,
              ),
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
