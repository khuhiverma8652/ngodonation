import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import 'package:ngo_donation_app/services/api_service.dart';

class VolunteerHomeScreen extends StatefulWidget {
  const VolunteerHomeScreen({Key? key}) : super(key: key);

  @override
  State<VolunteerHomeScreen> createState() => _VolunteerHomeScreenState();
}

class _VolunteerHomeScreenState extends State<VolunteerHomeScreen> {
String campaignId = "";
  bool _isLoading = true;
  List<dynamic> _opportunities = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOpportunities();
  }

  Future<void> _loadOpportunities() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      
      final response = await ApiService.joinVolunteer(campaignId);
      if (response['success']) {
        setState(() {
          _opportunities = response['opportunities'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading opportunities: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'What can I do today?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF00BCD4),
                      Color(0xFF0097A7),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -40,
                      top: 30,
                      child: Icon(
                        Icons.volunteer_activism,
                        size: 150,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    const Center(
                      child: Icon(
                        Icons.favorite_border,
                        size: 70,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Quick stats
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00BCD4).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickStat(
                    Icons.today,
                    '${_opportunities.length}',
                    'Today',
                  ),
                  Container(width: 1, height: 40, color: Colors.white30),
                  _buildQuickStat(
                    Icons.location_on,
                    '< 5km',
                    'Nearby',
                  ),
                  Container(width: 1, height: 40, color: Colors.white30),
                  _buildQuickStat(
                    Icons.schedule,
                    'Now',
                    'Available',
                  ),
                ],
              ),
            ).animate().fadeIn().scale(delay: 200.ms),
          ),

          // CTA message
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.cyan.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.cyan.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF00BCD4)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'No long forms. Just clear actions.',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // Section header
          SliverToBoxAdapter(
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Opportunities Near You',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ).animate(delay: 400.ms).fadeIn(),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // Loading
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),

          // Error
          if (!_isLoading && _errorMessage != null)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 80, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(_errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                          _errorMessage = null;
                        });
                        _loadOpportunities();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),

          // Empty
          if (!_isLoading && _errorMessage == null && _opportunities.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 100, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    const Text(
                      'No opportunities today',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Check back tomorrow!',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),

          // Opportunities list
          if (!_isLoading && _errorMessage == null && _opportunities.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final opportunity = _opportunities[index];
                    return _buildOpportunityCard(opportunity, index);
                  },
                  childCount: _opportunities.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildQuickStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildOpportunityCard(Map<String, dynamic> opportunity, int index) {
    final categoryColor = _getCategoryColor(opportunity['category'] ?? 'Food');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [categoryColor.withOpacity(0.8), categoryColor],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getCategoryIcon(opportunity['category']),
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        opportunity['title'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  opportunity['ngoName'] ?? '',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDetailRow(
                  Icons.access_time,
                  'Time',
                  opportunity['time'] ?? '',
                  categoryColor,
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.location_on,
                  'Location',
                  '${opportunity['distance']?.toStringAsFixed(1) ?? '0'} km away',
                  categoryColor,
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.group,
                  'Volunteers Needed',
                  '${opportunity['volunteersNeeded'] ?? 0} more',
                  categoryColor,
                ),
                if (opportunity['skill'] != null) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.star,
                    'Skill',
                    opportunity['skill'],
                    categoryColor,
                  ),
                ],
                const SizedBox(height: 20),
                
                // Action button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // Join volunteer opportunity
                      try {
                        final response = await ApiService.joinVolunteer(campaignId);


                        
                        if (response['success'] && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Successfully joined!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          _loadOpportunities();
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text(
                      'Join Now',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: categoryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: (100 * index + 500).ms)
      .fadeIn(duration: 500.ms)
      .slideY(begin: 0.2, end: 0);
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return const Color(0xFFFF5252);
      case 'medical':
        return const Color(0xFF00BCD4);
      case 'education':
        return const Color(0xFF9C27B0);
      case 'emergency':
        return const Color(0xFFFF6F00);
      default:
        return Colors.blue;
    }
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
        return Icons.warning;
      default:
        return Icons.volunteer_activism;
    }
  }
}