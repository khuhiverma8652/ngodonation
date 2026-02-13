import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ngo_donation_app/services/api_service.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  final Set<Marker> _markers = {};
  bool _isLoading = true;
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Food',
    'Medical',
    'Education',
    'Emergency'
  ];

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
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getMapCampaigns(
        latitude: lat,
        longitude: lon,
        maxDistance: 50000,
        category: _selectedCategory,
      );

      final ngos = response['campaigns'] ?? response['data'] ?? [];

      Set<Marker> markers = {};

      // Current location marker
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(lat, lon),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: "Your Location"),
        ),
      );

      // NGO/Campaign markers
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
                title: ngo['title'] ?? ngo['name'] ?? 'NGO',
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
        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
        : _defaultLocation;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nearby NGO Projects"),
        backgroundColor: const Color(0xFF6200EE),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          _isLoading
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
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedCategory == _categories[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_categories[index]),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = _categories[index];
                          _loadNGOs(
                              startPosition.latitude, startPosition.longitude);
                        });
                      },
                      selectedColor: const Color(0xFF6200EE),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6200EE),
        child: const Icon(Icons.my_location),
        onPressed: () {
          if (_currentPosition != null) {
            _mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(
                LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
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
