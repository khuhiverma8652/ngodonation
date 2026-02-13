import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'ngo/quick_campaign_creator.dart';
import 'package:ngo_donation_app/services/api_service.dart';

class NGODashboard extends StatefulWidget {
  const NGODashboard({super.key});

  @override
  State<NGODashboard> createState() => _NGODashboardState();
}

class _NGODashboardState extends State<NGODashboard> {
  int _selectedIndex = 0;
  bool _isLoading = true;

  Map<String, dynamic> _stats = {
    'totalCampaigns': 0,
    'activeCampaigns': 0,
    'totalRaised': 0,
    'totalDonors': 0,
  };

  List<dynamic> _campaigns = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.getNGODashboard();
      final success = response['success'] ?? false;

      if (success) {
        setState(() {
          _campaigns = response['campaigns'] ?? [];
          _stats = Map<String, dynamic>.from(response['stats'] ??
              {
                'totalCampaigns': 0,
                'activeCampaigns': 0,
                'totalRaised': 0,
                'totalDonors': 0,
              });
        });
      }
    } catch (e) {
      debugPrint("Dashboard load error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (_selectedIndex != 0) {
          setState(() => _selectedIndex = 0);
        }
      },
      child: Scaffold(
        body: _selectedIndex == 0 ? _buildHome() : _buildCampaigns(),
        bottomNavigationBar: _buildBottomNav(),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const QuickCampaignCreator(),
              ),
            ).then((_) => _loadDashboardData());
          },
          icon: const Icon(Icons.add),
          label: const Text('New Campaign'),
          backgroundColor: const Color(0xFFFF5252),
        ).animate().scale(delay: 400.ms),
      ),
    );
  }

  Widget _buildHome() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: const Text(
              'NGO Dashboard',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF5252), Color(0xFFE91E63)],
                ),
              ),
              child: const Center(
                child: Icon(Icons.business, size: 70, color: Colors.white30),
              ),
            ),
          ),
        ),
        if (!_isLoading)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Campaigns',
                          '${_stats['totalCampaigns']}',
                          Icons.campaign,
                          const Color(0xFFFF5252),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Active',
                          '${_stats['activeCampaigns']}',
                          Icons.trending_up,
                          const Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Raised',
                          '₹${_stats['totalRaised']}',
                          Icons.currency_rupee,
                          const Color(0xFF2196F3),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Donors',
                          '${_stats['totalDonors']}',
                          Icons.people,
                          const Color(0xFF9C27B0),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.2),
          ),
        _buildQuickActions(),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildQuickActions() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    'Send Update',
                    Icons.send,
                    const Color(0xFF00BCD4),
                    () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    'Thank Donors',
                    Icons.favorite,
                    const Color(0xFFE91E63),
                    () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    'Request Support',
                    Icons.help_outline,
                    const Color(0xFFFF9800),
                    () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    'View Reports',
                    Icons.bar_chart,
                    const Color(0xFF9C27B0),
                    () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ).animate(delay: 200.ms).fadeIn(),
    );
  }

  Widget _buildCampaigns() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_campaigns.isEmpty) {
      return const Center(child: Text('No campaigns yet'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _campaigns.length,
      itemBuilder: (_, i) => _buildCampaignCard(_campaigns[i]),
    );
  }

  Widget _buildCampaignCard(Map<String, dynamic> campaign) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
          Text(
            campaign['title'] ?? '',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: ((campaign['currentAmount'] ?? 0) /
                    (campaign['targetAmount'] ?? 1))
                .clamp(0.0, 1.0),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildActionCard(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (i) => setState(() => _selectedIndex = i),
      selectedItemColor: const Color(0xFFFF5252),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.campaign), label: 'Campaigns'),
      ],
    );
  }
}
