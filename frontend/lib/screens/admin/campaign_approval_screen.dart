import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ngo_donation_app/services/api_service.dart';

class CampaignApprovalScreen extends StatefulWidget {
  const CampaignApprovalScreen({super.key});

  @override
  State<CampaignApprovalScreen> createState() => _CampaignApprovalScreenState();
}

class _CampaignApprovalScreenState extends State<CampaignApprovalScreen> {
  bool _isLoading = true;
  List<dynamic> _pendingCampaigns = [];
  final String _filter = 'All';

  final List<String> _filters = [
    'All',
    'Food',
    'Medical',
    'Education',
    'Emergency'
  ];

  @override
  void initState() {
    super.initState();
    _loadPendingCampaigns();
  }

  Future<void> _loadPendingCampaigns() async {
    try {
      final response = await ApiService.getPendingCampaigns();
      if (response['success']) {
        setState(() {
          _pendingCampaigns = response['campaigns'];
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  List<dynamic> get filteredCampaigns {
    if (_filter == 'All') return _pendingCampaigns;
    return _pendingCampaigns.where((c) => c['category'] == _filter).toList();
  }

  Future<void> _approveCampaign(String id) async {
    await ApiService.updateCampaignStatus(id, "approved");
    if (!mounted) return;
    _loadPendingCampaigns();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text(
                'Campaign Approval',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Icon(
                        Icons.verified_user,
                        size: 200,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    const Center(
                      child: Icon(
                        Icons.admin_panel_settings,
                        size: 80,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF6200EE)),
              ),
            )
          else if (filteredCampaigns.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2_outlined,
                        size: 80, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'No pending campaigns found',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final campaign = filteredCampaigns[index];
                    return _buildModernCampaignCard(campaign, index);
                  },
                  childCount: filteredCampaigns.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildModernCampaignCard(Map<String, dynamic> campaign, int index) {
    final categoryColor = _getCategoryColor(campaign['category'] ?? '');
    final List images = campaign['images'] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Category and Title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.1),
              border: Border(left: BorderSide(color: categoryColor, width: 6)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: categoryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getCategoryIcon(campaign['category'] ?? ''),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (campaign['category'] ?? 'OTHER').toUpperCase(),
                        style: TextStyle(
                          color: categoryColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                      Text(
                        campaign['title'] ?? 'Untitled Campaign',
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3436),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Image Preview if available
          if (images.isNotEmpty)
            SizedBox(
              height: 180,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                itemBuilder: (context, i) => Container(
                  width: 250,
                  margin: const EdgeInsets.only(right: 12, top: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(images[i]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Detailed Info Sections
                _buildSectionHeader("Campaign Mission"),
                Text(
                  campaign['description'] ?? 'No description provided.',
                  style: TextStyle(color: Colors.grey.shade700, height: 1.5),
                ),
                const SizedBox(height: 15),
                _buildSectionHeader("Why it Matters"),
                Text(
                  campaign['whyMatters'] ?? 'N/A',
                  style: TextStyle(color: Colors.grey.shade700, height: 1.5),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Divider(),
                ),

                // Grid of Facts
                Row(
                  children: [
                    _buildInfoTile(
                      Icons.currency_rupee,
                      "Target",
                      "₹${campaign['targetAmount']?.toString() ?? '0'}",
                      Colors.green,
                    ),
                    _buildInfoTile(
                      Icons.event,
                      "Start Date",
                      _formatDate(campaign['startDate']),
                      Colors.blue,
                    ),
                    _buildInfoTile(
                      Icons.event_available,
                      "End Date",
                      _formatDate(campaign['endDate']),
                      Colors.orange,
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // Itemized Needs if exists
                if (campaign['needs'] != null &&
                    (campaign['needs'] as List).isNotEmpty) ...[
                  _buildSectionHeader("Itemized Needs"),
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: (campaign['needs'] as List).map((need) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_outline,
                                  size: 16, color: categoryColor),
                              const SizedBox(width: 10),
                              Text(
                                "${need['item']}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                              const Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "${need['quantity']} units",
                                    style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 13),
                                  ),
                                  if (need['estimatedCost'] != null)
                                    Text(
                                      "Est. ₹${need['estimatedCost']}",
                                      style: TextStyle(
                                          color: Colors.green.shade600,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Divider(),
                ),

                // NGO Section
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFF6200EE),
                      child: Text(
                        (campaign['ngoId']?['ngoName'] ??
                                campaign['ngoId']?['name'] ??
                                "N")[0]
                            .toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            campaign['ngoId']?['ngoName'] ??
                                campaign['ngoId']?['name'] ??
                                'Anonymous NGO',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          Text(
                            campaign['ngoId']?['email'] ?? 'No email',
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildContactRow(
                    Icons.location_on, _formatAddress(campaign['ngoId'])),
                _buildContactRow(
                    Icons.phone, campaign['ngoId']?['phone'] ?? 'N/A'),

                const SizedBox(height: 25),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showRejectDialog(campaign['_id']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.red,
                          elevation: 0,
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side:
                                const BorderSide(color: Colors.red, width: 1.5),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.close_rounded, size: 20),
                            SizedBox(width: 8),
                            Text("REJECT",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _approveCampaign(campaign['_id']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6200EE),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(16),
                          elevation: 4,
                          shadowColor: const Color(0xFF6200EE).withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_rounded, size: 20),
                            SizedBox(width: 8),
                            Text("APPROVE",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate(delay: (100 * index).ms)
        .fadeIn()
        .scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOutBack);
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildInfoTile(
      IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Color(0xFF2D3436),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String info) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade500),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              info,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return "N/A";
    try {
      return date.split('T')[0];
    } catch (_) {
      return date.toString();
    }
  }

  String _formatAddress(Map? ngo) {
    if (ngo == null) return "N/A";
    final parts = [ngo['address'], ngo['ngoAddress'], ngo['city'], ngo['state']]
        .where((e) => e != null && e.toString().trim().isNotEmpty)
        .toList();
    return parts.isEmpty ? "No address listed" : parts.join(", ");
  }

  void _showRejectDialog(String id) {
    final TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reject Campaign"),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            hintText: "Enter rejection reason...",
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () async {
              await ApiService.updateCampaignStatus(id, "rejected",
                  reason: reasonController.text);
              Navigator.pop(context);
              _loadPendingCampaigns();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("REJECT", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return const Color(0xFFFF7675);
      case 'medical':
        return const Color(0xFF00CEC9);
      case 'education':
        return const Color(0xFF6C5CE7);
      case 'emergency':
        return const Color(0xFFD63031);
      default:
        return const Color(0xFF0984E3);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant_rounded;
      case 'medical':
        return Icons.medical_services_rounded;
      case 'education':
        return Icons.school_rounded;
      case 'emergency':
        return Icons.warning_amber_rounded;
      default:
        return Icons.volunteer_activism_rounded;
    }
  }
}
