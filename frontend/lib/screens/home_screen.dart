import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({
    super.key,
    required this.user,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _stats;
  final List<dynamic> _recentActivity = [];

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    try {
      // Load different data based on user role
      if (widget.user.isDonor) {
        await _loadDonorHome();
      } else if (widget.user.isNGO) {
        await _loadNGOHome();
      } else if (widget.user.isVolunteer) {
        await _loadVolunteerHome();
      } else if (widget.user.isAdmin) {
        await _loadAdminHome();
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadDonorHome() async {
    // Load donor-specific data
    final response = await ApiService.getImpact();
    if (response['success']) {
      setState(() {
        _stats = response['data'];
      });
    }
  }

  Future<void> _loadNGOHome() async {
    // Load NGO-specific data
    final response = await ApiService.getNGODashboard();
    if (response['success']) {
      setState(() {
        _stats = response['stats'];
      });
    }
  }

  Future<void> _loadVolunteerHome() async {
    // Load volunteer-specific data
    final response = await ApiService.getVolunteerProgress();
    if (response['success']) {
      setState(() {
        _stats = response['data'];
      });
    }
  }

  Future<void> _loadAdminHome() async {
    // Load admin-specific data
    final response = await ApiService.getAdminStats();
    if (response['success']) {
      setState(() {
        _stats = response['stats'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          _buildAppBar(),

          // Welcome Section
          SliverToBoxAdapter(
            child: _buildWelcomeSection(),
          ),

          // Stats Section
          if (!_isLoading && _stats != null)
            SliverToBoxAdapter(
              child: _buildStatsSection(),
            ),

          // Quick Actions
          SliverToBoxAdapter(
            child: _buildQuickActions(),
          ),

          // Loading indicator
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    Color primaryColor = _getRoleColor();

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Home',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor,
                primaryColor.withValues(alpha: 0.7),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -50,
                top: 30,
                child: Icon(
                  _getRoleIcon(),
                  size: 150,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              Center(
                child: Icon(
                  _getRoleIcon(),
                  size: 70,
                  color: Colors.white30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getRoleColor(),
            _getRoleColor().withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getRoleColor().withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: widget.user.profileImage != null
                    ? ClipOval(
                        child: Image.network(
                          widget.user.profileImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person,
                              size: 30,
                              color: _getRoleColor(),
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.person,
                        size: 30,
                        color: _getRoleColor(),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome Back,',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.user.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.user.displayRole,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getWelcomeMessage(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildStatsSection() {
    if (widget.user.isDonor) {
      return _buildDonorStats();
    } else if (widget.user.isNGO) {
      return _buildNGOStats();
    } else if (widget.user.isVolunteer) {
      return _buildVolunteerStats();
    } else if (widget.user.isAdmin) {
      return _buildAdminStats();
    }
    return const SizedBox.shrink();
  }

  Widget _buildDonorStats() {
    final totalDonated = _stats?['totalDonated'] ?? 0;
    final campaignsSupported = _stats?['campaignsSupported'] ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Impact',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '₹$totalDonated',
                  'Total Donated',
                  Icons.currency_rupee,
                  const Color(0xFF6200EE),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '$campaignsSupported',
                  'Campaigns',
                  Icons.campaign,
                  const Color(0xFFE91E63),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2);
  }

  Widget _buildNGOStats() {
    final totalCampaigns = _stats?['totalCampaigns'] ?? 0;
    final totalRaised = _stats?['totalRaised'] ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Dashboard',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '$totalCampaigns',
                  'Campaigns',
                  Icons.campaign,
                  const Color(0xFFFF5252),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '₹$totalRaised',
                  'Total Raised',
                  Icons.trending_up,
                  const Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2);
  }

  Widget _buildVolunteerStats() {
    final eventsAttended = _stats?['totalEvents'] ?? 0;
    final totalHours = _stats?['totalHours'] ?? 0;
    final badge = _stats?['currentBadge'] ?? 'Beginner';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Progress',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.military_tech,
                  size: 50,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(
                          '$eventsAttended',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Events',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white30,
                    ),
                    Column(
                      children: [
                        Text(
                          '$totalHours',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Hours',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: 300.ms).fadeIn().scale();
  }

  Widget _buildAdminStats() {
    final totalUsers = _stats?['totalUsers'] ?? 0;
    final pendingCampaigns = _stats?['pendingCampaigns'] ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Platform Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '$totalUsers',
                  'Total Users',
                  Icons.people,
                  const Color(0xFF2196F3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '$pendingCampaigns',
                  'Pending',
                  Icons.pending,
                  const Color(0xFFFF9800),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2);
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._getQuickActions().map((action) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildActionButton(
                action['title'],
                action['icon'],
                action['color'],
                action['onTap'],
              ),
            );
          }),
        ],
      ),
    ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2);
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getQuickActions() {
    if (widget.user.isDonor) {
      return [
        {
          'title': 'Browse Campaigns',
          'icon': Icons.explore,
          'color': const Color(0xFF6200EE),
          'onTap': () {
            // Navigate to campaigns
          },
        },
        {
          'title': 'Donation History',
          'icon': Icons.history,
          'color': const Color(0xFFE91E63),
          'onTap': () {
            // Navigate to history
          },
        },
        {
          'title': 'My Impact',
          'icon': Icons.favorite,
          'color': const Color(0xFFFF5252),
          'onTap': () {
            // Navigate to impact
          },
        },
      ];
    } else if (widget.user.isNGO) {
      return [
        {
          'title': 'Create Campaign',
          'icon': Icons.add_circle,
          'color': const Color(0xFFFF5252),
          'onTap': () {
            // Navigate to create campaign
          },
        },
        {
          'title': 'My Campaigns',
          'icon': Icons.campaign,
          'color': const Color(0xFF4CAF50),
          'onTap': () {
            // Navigate to campaigns
          },
        },
        {
          'title': 'Analytics',
          'icon': Icons.bar_chart,
          'color': const Color(0xFF2196F3),
          'onTap': () {
            // Navigate to analytics
          },
        },
      ];
    } else if (widget.user.isVolunteer) {
      return [
        {
          'title': 'Find Opportunities',
          'icon': Icons.search,
          'color': const Color(0xFF00BCD4),
          'onTap': () {
            // Navigate to opportunities
          },
        },
        {
          'title': 'My Progress',
          'icon': Icons.trending_up,
          'color': const Color(0xFF9C27B0),
          'onTap': () {
            // Navigate to progress
          },
        },
        {
          'title': 'Leaderboard',
          'icon': Icons.emoji_events,
          'color': const Color(0xFFFF9800),
          'onTap': () {
            // Navigate to leaderboard
          },
        },
      ];
    } else if (widget.user.isAdmin) {
      return [
        {
          'title': 'Approve Campaigns',
          'icon': Icons.check_circle,
          'color': const Color(0xFF4CAF50),
          'onTap': () {
            // Navigate to approvals
          },
        },
        {
          'title': 'Manage Users',
          'icon': Icons.people,
          'color': const Color(0xFF2196F3),
          'onTap': () {
            // Navigate to users
          },
        },
        {
          'title': 'Platform Analytics',
          'icon': Icons.analytics,
          'color': const Color(0xFF9C27B0),
          'onTap': () {
            // Navigate to analytics
          },
        },
      ];
    }
    return [];
  }

  Color _getRoleColor() {
    if (widget.user.isDonor) return const Color(0xFF6200EE);
    if (widget.user.isNGO) return const Color(0xFFFF5252);
    if (widget.user.isVolunteer) return const Color(0xFF00BCD4);
    if (widget.user.isAdmin) return const Color(0xFF9C27B0);
    return const Color(0xFF6200EE);
  }

  IconData _getRoleIcon() {
    if (widget.user.isDonor) return Icons.volunteer_activism;
    if (widget.user.isNGO) return Icons.business;
    if (widget.user.isVolunteer) return Icons.favorite;
    if (widget.user.isAdmin) return Icons.admin_panel_settings;
    return Icons.person;
  }

  String _getWelcomeMessage() {
    if (widget.user.isDonor) {
      return 'Every donation makes a difference in someone\'s life!';
    } else if (widget.user.isNGO) {
      return 'Your campaigns are changing lives in the community!';
    } else if (widget.user.isVolunteer) {
      return 'Thank you for making a difference with your time!';
    } else if (widget.user.isAdmin) {
      return 'Managing the platform to help thousands of people!';
    }
    return 'Welcome to the NGO Donation Platform!';
  }
}
