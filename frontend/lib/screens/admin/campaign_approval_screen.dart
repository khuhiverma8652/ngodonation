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
    _loadPendingCampaigns();
  }

  Future<void> _rejectCampaign(String id) async {
    await ApiService.updateCampaignStatus(id, "rejected");
    _loadPendingCampaigns();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Campaign Approval',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6200EE), Color(0xFF3700B3)],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.admin_panel_settings,
                    size: 70,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (filteredCampaigns.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text(
                  'No pending campaigns',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final campaign = filteredCampaigns[index];
                    return _buildCampaignCard(campaign, index);
                  },
                  childCount: filteredCampaigns.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildCampaignCard(Map<String, dynamic> campaign, int index) {
    final categoryColor = _getCategoryColor(campaign['category'] ?? '');

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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  categoryColor.withOpacity(0.8),
                  categoryColor,
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getCategoryIcon(campaign['category'] ?? ''),
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    campaign['title'] ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(
                  Icons.location_on,
                  'Location',
                  campaign['area'] ?? '',
                ),
                const SizedBox(height: 8),

                // ✅ NGO DETAILS ADDED SAFELY
                _buildDetailRow(
                  Icons.business,
                  'NGO',
                  campaign['ngoId']?['name'] ?? '',
                ),
                const SizedBox(height: 8),

                _buildDetailRow(
                  Icons.email,
                  'Email',
                  campaign['ngoId']?['email'] ?? '',
                ),
                const SizedBox(height: 8),

                _buildDetailRow(
                  Icons.phone,
                  'Phone',
                  campaign['ngoId']?['phone'] ?? '',
                ),
                const SizedBox(height: 8),

                _buildDetailRow(
                  Icons.calendar_today,
                  'Date',
                  campaign['date'] ?? '',
                ),
                const SizedBox(height: 8),

                _buildDetailRow(
                  Icons.access_time,
                  'Time',
                  campaign['time'] ?? '',
                ),
                const SizedBox(height: 8),

                _buildDetailRow(
                  Icons.currency_rupee,
                  'Target Amount',
                  '₹${campaign['targetAmount'] ?? 0}',
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _rejectCampaign(campaign['_id']),
                        icon: const Icon(Icons.close),
                        label: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _approveCampaign(campaign['_id']),
                        icon: const Icon(Icons.check),
                        label: const Text('Approve'),
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
        .animate(delay: (100 * index + 400).ms)
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
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
