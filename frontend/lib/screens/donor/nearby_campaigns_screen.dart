import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:ngo_donation_app/services/api_service.dart';
import '../campaign_detail_screen.dart';

class NearbyCampaignsScreen extends StatefulWidget {
  const NearbyCampaignsScreen({super.key});

  @override
  State<NearbyCampaignsScreen> createState() => _NearbyCampaignsScreenState();
}

class _NearbyCampaignsScreenState extends State<NearbyCampaignsScreen> {
  List<dynamic> _campaigns = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  Position? _currentPosition;

  final List<String> _categories = [
    'All',
    'Food',
    'Medical',
    'Education',
    'Emergency'
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _loadCampaigns(19.0760, 72.8777);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _loadCampaigns(19.0760, 72.8777);
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() => _currentPosition = position);
      }
      _loadCampaigns(position.latitude, position.longitude);
    } catch (e) {
      _loadCampaigns(19.0760, 72.8777);
    }
  }

  Future<void> _loadCampaigns(double lat, double lon) async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.getNearbyCampaigns(
        latitude: lat,
        longitude: lon,
        maxDistance: 50000,
        category: _selectedCategory == 'All' ? null : _selectedCategory,
      );

      if (mounted) {
        setState(() {
          _campaigns = response['campaigns'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Nearby Campaigns',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _getCurrentLocation(),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () {
              ApiService.clearToken();
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            },
            icon: const Icon(Icons.exit_to_app, color: Colors.red),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Selector
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
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
                        if (_currentPosition != null) {
                          _loadCampaigns(_currentPosition!.latitude,
                              _currentPosition!.longitude);
                        } else {
                          _loadCampaigns(19.0760, 72.8777);
                        }
                      });
                    },
                    selectedColor: const Color(0xFF6200EE),
                    backgroundColor: Colors.grey.shade100,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _campaigns.isEmpty
                    ? const Center(child: Text("No campaigns found nearby"))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _campaigns.length,
                        itemBuilder: (context, index) {
                          return _buildDetailedCampaignCard(
                              _campaigns[index], index);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedCampaignCard(Map<String, dynamic> campaign, int index) {
    final title = campaign['title'] ?? 'Help Needed';
    final category = campaign['category'] ?? 'General';
    final ngoName = campaign['ngoId']?['name'] ?? 'NGO Name';
    final location =
        campaign['location']?['area'] ?? campaign['area'] ?? 'Unknown Location';
    final city = campaign['location']?['city'] ?? '';
    final distance = (campaign['distance'] ?? 0.0).toStringAsFixed(1);
    final target = (campaign['targetAmount'] ?? 0).toDouble();
    final raised = (campaign['currentAmount'] ?? 0).toDouble();
    final progress = target > 0 ? (raised / target).clamp(0.0, 1.0) : 0.0;

    final categoryColor = _getCategoryColor(category);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Tag and Distance
          Stack(
            children: [
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [categoryColor.withOpacity(0.8), categoryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Center(
                  child: Icon(
                    _getCategoryIcon(category),
                    size: 60,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category.toUpperCase(),
                    style: TextStyle(
                      color: categoryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        "$distance km",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.business, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      ngoName,
                      style: const TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                    const Text(" • ", style: TextStyle(color: Colors.grey)),
                    const Icon(Icons.room, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        "$location${city.isNotEmpty ? ', $city' : ''}",
                        style: const TextStyle(color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "₹${NumberFormat('#,##,###').format(raised)} raised",
                          style: const TextStyle(
                            color: Color(0xFF6200EE),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${(progress * 100).toStringAsFixed(1)}% complete",
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                    Text(
                      "Target: ₹${NumberFormat('#,##,###').format(target)}",
                      style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: Colors.grey.shade100,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFF6200EE)),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CampaignDetailScreen(campaign: campaign),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6200EE),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Support Now",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: (index * 100).ms)
        .slideY(begin: 0.1);
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'medical':
        return Icons.medical_services;
      case 'education':
        return Icons.school;
      case 'emergency':
        return Icons.emergency_share;
      default:
        return Icons.volunteer_activism;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Colors.orange;
      case 'medical':
        return Colors.red;
      case 'education':
        return Colors.blue;
      case 'emergency':
        return Colors.deepOrange;
      default:
        return Colors.purple;
    }
  }
}
