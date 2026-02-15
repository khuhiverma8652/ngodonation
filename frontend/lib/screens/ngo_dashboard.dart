import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'ngo/quick_campaign_creator.dart';
import 'ngo/donation_reports_screen.dart';
import 'ngo/thank_donors_screen.dart';
import 'ngo/send_update_screen.dart';
import 'ngo/verify_item_donations_screen.dart';
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
  List<dynamic> _recentDonations = [];
  List<dynamic> _pendingVerifications = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getNGODashboard();
      if (response['success'] == true) {
        final donations = response['donations'] ?? [];
        setState(() {
          _campaigns = response['campaigns'] ?? [];
          _recentDonations = donations;

          // CRITICAL: Items that are NOT Food and NOT Verified stay in Pending
          _pendingVerifications = donations.where((d) {
            final type = d['donationType'] ?? 'monetary';
            final isVerified = d['isVerifiedByNGO'] == true;
            final category = d['campaignId']?['category'] ?? '';
            return type == 'in-kind' && !isVerified && category != 'Food';
          }).toList();

          _stats = Map<String, dynamic>.from(response['stats'] ?? {});
        });
      }
    } catch (e) {
      debugPrint("Dashboard refresh error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F7),
      body: _isLoading && _recentDonations.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE91E63)))
          : _selectedIndex == 0
              ? _buildMonitor()
              : _buildMissions(),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const QuickCampaignCreator()))
                  .then((_) => _loadDashboardData()),
              backgroundColor: const Color(0xFFE91E63),
              child: const Icon(Icons.add_task, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildMonitor() {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: CustomScrollView(
        slivers: [
          _buildPremiumHeader(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: _buildStatRow(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: _buildActionGrid(),
            ),
          ),
          if (_pendingVerifications.isNotEmpty)
            SliverToBoxAdapter(child: _buildPendingHub()),
          SliverToBoxAdapter(
              child: _buildSectionHeader(
                  "Active Support Lines", "Current mission telemetry")),
          _buildHorizontalMissions(),
          SliverToBoxAdapter(
              child: _buildSectionHeader("Verified Successful Donations",
                  "Permanent record of impact")),
          _buildSuccessLog(),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF1E1E2C),
      actions: [
        IconButton(
          onPressed: () {
            ApiService.clearToken();
            Navigator.pushNamedAndRemoveUntil(
                context, '/login', (route) => false);
          },
          icon: const Icon(Icons.exit_to_app, color: Colors.white),
          tooltip: 'Sign Out',
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E1E2C), Color(0xFF2D2D44)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                  right: -30,
                  top: -30,
                  child: Icon(Icons.shield_outlined,
                      size: 200, color: Colors.white.withOpacity(0.05))),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("NGO COMMAND UNIT",
                        style: TextStyle(
                            color: Color(0xFFE91E63),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2)),
                    const SizedBox(height: 8),
                    const Text("Giving Foundation",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildGlobalStatusBadge(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlobalStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white10)),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 4, backgroundColor: Colors.greenAccent),
          SizedBox(width: 8),
          Text("SYSTEMS ONLINE • REAL-TIME SYNC",
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 9,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatRow() {
    return Row(
      children: [
        Expanded(
            child: _buildMetricTile("Total Raised", "₹${_stats['totalRaised']}",
                Icons.account_balance_wallet, Colors.green)),
        const SizedBox(width: 12),
        Expanded(
            child: _buildMetricTile("Donor Base", "${_stats['totalDonors']}",
                Icons.favorite, Colors.orange)),
      ],
    );
  }

  Widget _buildMetricTile(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2D3436))),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActionGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildCircularAction(
            "Authorize",
            Icons.verified_user,
            Colors.blue,
            () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const VerifyItemDonationsScreen()))
                .then((_) => _loadDashboardData())),
        _buildCircularAction(
            "Broadcast",
            Icons.bolt,
            Colors.purple,
            () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SendUpdateScreen()))),
        _buildCircularAction(
            "Thank",
            Icons.sentiment_very_satisfied,
            Colors.pink,
            () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ThankDonorsScreen()))),
        _buildCircularAction(
            "Log",
            Icons.list_alt,
            Colors.orange,
            () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const DonationReportsScreen()))),
      ],
    );
  }

  Widget _buildCircularAction(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.1), blurRadius: 10)
                ]),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey)),
        ],
      ),
    );
  }

  Widget _buildPendingHub() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2D3436),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.qr_code_scanner, color: Colors.amber, size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("AWAITING AUTHORIZATION",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(
                    "${_pendingVerifications.length} package(s) are in the manual verification queue.",
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const VerifyItemDonationsScreen()))
                .then((_) => _loadDashboardData()),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white10,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            child: const Text("Go"),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalMissions() {
    final active = _campaigns.where((c) => c['status'] == 'approved').toList();
    if (active.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Container(
        height: 100,
        margin: const EdgeInsets.symmetric(vertical: 16),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: active.length,
          itemBuilder: (context, index) {
            final campaign = active[index];
            return Container(
              width: 200,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade100)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(campaign['title'] ?? 'Mission',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12),
                      maxLines: 1),
                  const SizedBox(height: 8),
                  Text(
                      campaign['category'] == 'Food'
                          ? "${campaign['currentAmount']} kg"
                          : (campaign['category'] == 'Education'
                              ? "${campaign['currentAmount']} units"
                              : "₹${campaign['currentAmount']}"),
                      style: const TextStyle(
                          color: Color(0xFFE91E63),
                          fontSize: 11,
                          fontWeight: FontWeight.w900)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSuccessLog() {
    // 🟢 Logical Shift: Monetary OR (In-kind AND (isVerified OR Category==Food))
    final successRecords = _recentDonations.where((d) {
      final type = d['donationType'] ?? 'monetary';
      final status = d['paymentStatus'] ?? 'pending';
      final isVerified = d['isVerifiedByNGO'] == true;
      final category = d['campaignId']?['category'] ?? '';

      return type == 'monetary'
          ? (status == 'success' || status == 'completed')
          : (isVerified || category == 'Food');
    }).toList();

    if (successRecords.isEmpty) {
      return SliverToBoxAdapter(child: _buildEmptyLog());
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final donation = successRecords[index];
          final isMonetary = donation['donationType'] != 'in-kind';

          return Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.01), blurRadius: 10)
                ]),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: isMonetary
                          ? Colors.green.withOpacity(0.05)
                          : Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(14)),
                  child: Icon(
                      isMonetary ? Icons.currency_rupee : Icons.inventory_2,
                      color: isMonetary ? Colors.green : Colors.blue,
                      size: 18),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(donation['donorName'] ?? 'Anonymous',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(
                          donation['campaignId']?['title'] ?? 'General Support',
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 11)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(isMonetary ? "₹${donation['amount']}" : "SHIFTED",
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: isMonetary ? Colors.green : Colors.blue,
                            fontSize: 14)),
                    const Icon(Icons.check_circle,
                        size: 12, color: Colors.greenAccent),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(delay: (index * 40).ms).slideX(begin: 0.1);
        },
        childCount: successRecords.length,
      ),
    );
  }

  Widget _buildEmptyLog() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          Icon(Icons.history_toggle_off, color: Colors.grey.shade200, size: 50),
          const SizedBox(height: 12),
          Text("No successful shifting detected yet.",
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String sub) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title.toUpperCase(),
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
        Text(sub, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
      ]),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (i) => setState(() => _selectedIndex = i),
      selectedItemColor: const Color(0xFFE91E63),
      unselectedItemColor: Colors.grey.shade400,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedLabelStyle:
          const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined), label: 'MONITOR'),
        BottomNavigationBarItem(
            icon: Icon(Icons.campaign_outlined), label: 'MISSIONS'),
      ],
    );
  }

  Widget _buildMissions() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _campaigns.length,
      itemBuilder: (_, i) => _buildMissionCard(_campaigns[i]),
    );
  }

  Widget _buildMissionCard(Map<String, dynamic> campaign) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(campaign['title'] ?? 'Mission',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(campaign['status'] ?? 'PENDING',
                      style: const TextStyle(
                          fontSize: 8, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 12),
          Text(
              campaign['category'] == 'Food'
                  ? "Collected: ${campaign['currentAmount']} kg / Goal: ${campaign['targetAmount']} kg"
                  : (campaign['category'] == 'Education'
                      ? "Collected: ${campaign['currentAmount']} units / Goal: ${campaign['targetAmount']} units"
                      : "Raised: ₹${campaign['currentAmount']} / Goal: ₹${campaign['targetAmount']}"),
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        ],
      ),
    );
  }
}
