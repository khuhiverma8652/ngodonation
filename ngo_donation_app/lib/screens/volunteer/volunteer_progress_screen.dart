import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import 'package:ngo_donation_app/services/api_service.dart';

class VolunteerProgressScreen extends StatefulWidget {
  const VolunteerProgressScreen({Key? key}) : super(key: key);

  @override
  State<VolunteerProgressScreen> createState() => _VolunteerProgressScreenState();
}

class _VolunteerProgressScreenState extends State<VolunteerProgressScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _progressData;

  final Map<String, Map<String, dynamic>> _badges = {
    'Beginner': {
      'color': const Color(0xFF9E9E9E),
      'icon': Icons.star_border,
      'range': '0-4 events',
    },
    'Helper': {
      'color': const Color(0xFF4CAF50),
      'icon': Icons.star_half,
      'range': '5-9 events',
    },
    'Contributor': {
      'color': const Color(0xFF2196F3),
      'icon': Icons.star,
      'range': '10-19 events',
    },
    'Champion': {
      'color': const Color(0xFFFF9800),
      'icon': Icons.workspace_premium,
      'range': '20-29 events',
    },
    'Hero': {
      'color': const Color(0xFFE91E63),
      'icon': Icons.military_tech,
      'range': '30-49 events',
    },
    'Legend': {
      'color': const Color(0xFF9C27B0),
      'icon': Icons.emoji_events,
      'range': '50+ events',
    },
  };

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      final response = await ApiService.getVolunteerProgress();
      
      if (response['success']) {
        setState(() {
          _progressData = response['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentBadge = _progressData?['currentBadge'] ?? 'Beginner';
    final totalEvents = _progressData?['totalEvents'] ?? 0;
    final totalHours = _progressData?['totalHours'] ?? 0;
    final totalScore = _progressData?['totalScore'] ?? 0;
    final nextBadge = _getNextBadge(currentBadge);
    final eventsToNext = _getEventsToNextBadge(totalEvents);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Your Progress',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _badges[currentBadge]!['color'],
                      _badges[currentBadge]!['color'].withOpacity(0.7),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    _badges[currentBadge]!['icon'],
                    size: 80,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
          ),

          // Current Badge
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _badges[currentBadge]!['color'],
                    _badges[currentBadge]!['color'].withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _badges[currentBadge]!['color'].withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    _badges[currentBadge]!['icon'],
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentBadge.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _badges[currentBadge]!['range'],
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms).scale(),
          ),

          // Stats
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      Icons.event,
                      totalEvents.toString(),
                      'Events',
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      Icons.access_time,
                      totalHours.toString(),
                      'Hours',
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      Icons.stars,
                      totalScore.toString(),
                      'Points',
                      Colors.orange,
                    ),
                  ),
                ],
              ),
            ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2),
          ),

          // Progress to next badge
          if (nextBadge != null)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.trending_up,
                          color: _badges[nextBadge]!['color'],
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Next Badge',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          _badges[nextBadge]!['icon'],
                          size: 40,
                          color: _badges[nextBadge]!['color'],
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nextBadge,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: _badges[nextBadge]!['color'],
                              ),
                            ),
                            Text(
                              '$eventsToNext events to go!',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _getProgressToNextBadge(totalEvents),
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(
                          _badges[nextBadge]!['color'],
                        ),
                        minHeight: 10,
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2),
            ),

          // All Badges
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Text(
                'Badge Progression',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final badgeName = _badges.keys.toList()[index];
                  final isUnlocked = _isBadgeUnlocked(badgeName, totalEvents);
                  
                  return _buildBadgeCard(
                    badgeName,
                    _badges[badgeName]!,
                    isUnlocked,
                    index,
                  );
                },
                childCount: _badges.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard(
    String name,
    Map<String, dynamic> badge,
    bool isUnlocked,
    int index,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnlocked ? badge['color'].withOpacity(0.1) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnlocked ? badge['color'].withOpacity(0.3) : Colors.grey.shade300,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            badge['icon'],
            size: 40,
            color: isUnlocked ? badge['color'] : Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isUnlocked ? badge['color'] : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            badge['range'],
            style: TextStyle(
              fontSize: 11,
              color: isUnlocked ? Colors.grey.shade700 : Colors.grey.shade500,
            ),
          ),
          if (!isUnlocked)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Icon(
                Icons.lock,
                size: 16,
                color: Colors.grey,
              ),
            ),
        ],
      ),
    ).animate(delay: (100 * index + 500).ms)
      .fadeIn(duration: 500.ms)
      .scale(begin: const Offset(0.8, 0.8));
  }

  String? _getNextBadge(String currentBadge) {
    final badges = _badges.keys.toList();
    final currentIndex = badges.indexOf(currentBadge);
    if (currentIndex < badges.length - 1) {
      return badges[currentIndex + 1];
    }
    return null;
  }

  int _getEventsToNextBadge(int totalEvents) {
    if (totalEvents < 5) return 5 - totalEvents;
    if (totalEvents < 10) return 10 - totalEvents;
    if (totalEvents < 20) return 20 - totalEvents;
    if (totalEvents < 30) return 30 - totalEvents;
    if (totalEvents < 50) return 50 - totalEvents;
    return 0;
  }

  double _getProgressToNextBadge(int totalEvents) {
    if (totalEvents < 5) return totalEvents / 5;
    if (totalEvents < 10) return (totalEvents - 5) / 5;
    if (totalEvents < 20) return (totalEvents - 10) / 10;
    if (totalEvents < 30) return (totalEvents - 20) / 10;
    if (totalEvents < 50) return (totalEvents - 30) / 20;
    return 1.0;
  }

  bool _isBadgeUnlocked(String badge, int totalEvents) {
    switch (badge) {
      case 'Beginner':
        return true;
      case 'Helper':
        return totalEvents >= 5;
      case 'Contributor':
        return totalEvents >= 10;
      case 'Champion':
        return totalEvents >= 20;
      case 'Hero':
        return totalEvents >= 30;
      case 'Legend':
        return totalEvents >= 50;
      default:
        return false;
    }
  }
}