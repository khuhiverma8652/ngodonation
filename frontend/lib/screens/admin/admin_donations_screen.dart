import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../theme/admin_theme.dart';

class AdminDonationsScreen extends StatefulWidget {
  const AdminDonationsScreen({super.key});

  @override
  State<AdminDonationsScreen> createState() => _AdminDonationsScreenState();
}

class _AdminDonationsScreenState extends State<AdminDonationsScreen> {
  bool _isLoading = true;
  List<dynamic> _donations = [];
  String _filterType = 'all'; // all, monetary, in-kind
  String _sortBy = 'date'; // date, amount

  // Summary stats
  double _totalAmount = 0;
  int _totalCount = 0;
  int _monetaryCount = 0;
  int _inKindCount = 0;
  double _avgDonation = 0;

  @override
  void initState() {
    super.initState();
    _fetchDonations();
  }

  Future<void> _fetchDonations() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getAdminDonations();
      if (response['success'] == true) {
        setState(() {
          _donations = response['data'] ?? [];
          _calculateStats();
        });
      }
    } catch (e) {
      debugPrint("Error fetching admin donations: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _calculateStats() {
    _totalCount = _donations.length;
    _totalAmount = 0;
    _monetaryCount = 0;
    _inKindCount = 0;

    for (var d in _donations) {
      final amount = (d['amount'] ?? 0).toDouble();
      _totalAmount += amount;
      if (d['donationType'] == 'in-kind') {
        _inKindCount++;
      } else {
        _monetaryCount++;
      }
    }
    _avgDonation = _totalCount > 0 ? _totalAmount / _totalCount : 0;
  }

  List<dynamic> get filteredDonations {
    var filtered = List<dynamic>.from(_donations);

    // Filter by type
    if (_filterType == 'monetary') {
      filtered = filtered.where((d) => d['donationType'] != 'in-kind').toList();
    } else if (_filterType == 'in-kind') {
      filtered = filtered.where((d) => d['donationType'] == 'in-kind').toList();
    }

    // Sort
    if (_sortBy == 'amount') {
      filtered.sort((a, b) =>
          ((b['amount'] ?? 0) as num).compareTo((a['amount'] ?? 0) as num));
    } else {
      filtered.sort((a, b) {
        final dateA = DateTime.tryParse(a['createdAt'] ?? '') ?? DateTime(2000);
        final dateB = DateTime.tryParse(b['createdAt'] ?? '') ?? DateTime(2000);
        return dateB.compareTo(dateA);
      });
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminTheme.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchDonations,
              child: CustomScrollView(
                slivers: [
                  // App Bar
                  SliverAppBar(
                    expandedHeight: 160,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      title: const Text('Donation Reports'),
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: AdminTheme.primaryGradient,
                        ),
                        child: const Center(
                          child: Icon(Icons.assessment,
                              size: 60, color: Colors.white24),
                        ),
                      ),
                    ),
                  ),

                  // Summary Cards
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Donations Overview',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildSummaryCard(
                                  'Total Raised',
                                  '₹${NumberFormat('#,##,###').format(_totalAmount)}',
                                  Icons.currency_rupee,
                                  const Color(0xFF4CAF50),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSummaryCard(
                                  'Total Donations',
                                  _totalCount.toString(),
                                  Icons.receipt_long,
                                  const Color(0xFF2196F3),
                                ),
                              ),
                            ],
                          ).animate().fadeIn().slideY(begin: 0.2),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildSummaryCard(
                                  'Monetary',
                                  _monetaryCount.toString(),
                                  Icons.payments,
                                  const Color(0xFFE91E63),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSummaryCard(
                                  'In-Kind',
                                  _inKindCount.toString(),
                                  Icons.inventory_2,
                                  const Color(0xFFFF9800),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSummaryCard(
                                  'Avg. Amount',
                                  '₹${NumberFormat('#,##,###').format(_avgDonation.round())}',
                                  Icons.trending_up,
                                  const Color(0xFF9C27B0),
                                ),
                              ),
                            ],
                          ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.2),
                        ],
                      ),
                    ),
                  ),

                  // Filters
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildFilterChip('All', 'all'),
                                  const SizedBox(width: 8),
                                  _buildFilterChip('Monetary', 'monetary'),
                                  const SizedBox(width: 8),
                                  _buildFilterChip('In-Kind', 'in-kind'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _sortBy,
                                icon: const Icon(Icons.sort, size: 18),
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.black87),
                                items: const [
                                  DropdownMenuItem(
                                      value: 'date', child: Text('By Date')),
                                  DropdownMenuItem(
                                      value: 'amount',
                                      child: Text('By Amount')),
                                ],
                                onChanged: (val) =>
                                    setState(() => _sortBy = val!),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Results count
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Text(
                        '${filteredDonations.length} donation${filteredDonations.length != 1 ? 's' : ''}',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ),
                  ),

                  // Donation List
                  if (filteredDonations.isEmpty)
                    const SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.receipt_long,
                                size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('No donations found',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 16)),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final donation = filteredDonations[index];
                            return _buildDonationCard(donation, index);
                          },
                          childCount: filteredDonations.length,
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String type) {
    final isSelected = _filterType == type;
    return GestureDetector(
      onTap: () => setState(() => _filterType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AdminTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AdminTheme.primary : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AdminTheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildDonationCard(Map<String, dynamic> donation, int index) {
    final donor = donation['donorId'] ?? {};
    final campaign = donation['campaignId'] ?? {};
    final ngo = donation['ngoId'] ?? {};
    final amount = (donation['amount'] ?? 0).toDouble();
    final date =
        DateTime.tryParse(donation['createdAt'] ?? '') ?? DateTime.now();
    final isAnonymous = donation['isAnonymous'] ?? false;
    final type = donation['donationType'] ?? 'monetary';
    final isMoney = type == 'monetary';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: EdgeInsets.zero,
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color:
                  (isMoney ? const Color(0xFF4CAF50) : const Color(0xFF2196F3))
                      .withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isMoney ? Icons.currency_rupee : Icons.inventory_2,
              color:
                  isMoney ? const Color(0xFF4CAF50) : const Color(0xFF2196F3),
              size: 22,
            ),
          ),
          title: Text(
            isAnonymous
                ? 'Anonymous Donor'
                : (donor['name'] ?? 'Unknown Donor'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text(
                isMoney
                    ? '₹${NumberFormat('#,##,###').format(amount)}'
                    : 'In-Kind Donation',
                style: TextStyle(
                  color: isMoney
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFF2196F3),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              Text(
                '→ ${campaign is Map ? campaign['title'] ?? 'Campaign' : 'Campaign'}',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('dd MMM yyyy').format(date),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
              ),
              const SizedBox(height: 2),
              Text(
                DateFormat('hh:mm a').format(date),
                style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
              ),
            ],
          ),
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section: Donor Info
                  _buildSectionHeader('Donor Information'),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.person, 'Donor Name',
                      isAnonymous ? 'Anonymous' : (donor['name'] ?? 'N/A')),
                  _buildInfoRow(Icons.email_outlined, 'Email',
                      isAnonymous ? 'Hidden' : (donor['email'] ?? 'N/A')),
                  if (!isAnonymous) ...[
                    _buildInfoRow(
                        Icons.phone_outlined, 'Phone', donor['phone'] ?? 'N/A'),
                    _buildInfoRow(Icons.home_outlined, 'Address',
                        donor['address'] ?? 'N/A'),
                    if (donor['location'] != null)
                      _buildInfoRow(Icons.location_on_outlined, 'Location',
                          donor['location'] ?? 'N/A'),
                  ],

                  const Divider(height: 24),

                  // Section: Donation Details
                  _buildSectionHeader('Donation Details'),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                      Icons.category, 'Type', type.toString().toUpperCase()),
                  if (!isMoney) ...[
                    _buildInfoRow(
                        Icons.verified,
                        'NGO Verification',
                        donation['isVerifiedByNGO'] == true
                            ? 'VERIFIED'
                            : 'PENDING',
                        color: donation['isVerifiedByNGO'] == true
                            ? Colors.green
                            : Colors.orange),
                    const SizedBox(height: 8),
                    const Text('Items:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 4),
                    ...(donation['items'] as List? ?? []).map((item) => Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 2),
                          child: Text(
                              '• ${item['name']} (Qty: ${item['quantity']})',
                              style: const TextStyle(fontSize: 12)),
                        )),
                  ],
                  if (isMoney)
                    _buildInfoRow(Icons.currency_rupee, 'Amount',
                        '₹${NumberFormat('#,##,###').format(amount)}'),
                  _buildInfoRow(
                      Icons.payment,
                      'Payment Mode',
                      donation['paymentMode']?.toString().toUpperCase() ??
                          'N/A'),
                  _buildInfoRow(
                      Icons.receipt,
                      'Transaction ID',
                      donation['transactionId'] ??
                          donation['paymentId'] ??
                          'N/A'),
                  _buildInfoRow(Icons.confirmation_number, 'Receipt No.',
                      donation['receiptNumber'] ?? 'N/A'),
                  _buildInfoRow(
                      Icons.verified,
                      'Payment Status',
                      (donation['paymentStatus'] ?? 'N/A')
                          .toString()
                          .toUpperCase()),

                  // In-kind items
                  if (type == 'in-kind' && donation['items'] != null) ...[
                    const Divider(height: 24),
                    _buildSectionHeader('Items Donated'),
                    const SizedBox(height: 8),
                    ...(donation['items'] as List).map((item) => Padding(
                          padding: const EdgeInsets.only(left: 4, top: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.circle,
                                  size: 6, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${item['name']} — Qty: ${item['quantity']}${item['value'] != null ? ' (₹${item['value']})' : ''}',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],

                  const Divider(height: 24),

                  // Section: Campaign & NGO
                  _buildSectionHeader('Campaign & NGO'),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.campaign, 'Campaign',
                      campaign is Map ? campaign['title'] ?? 'N/A' : 'N/A'),
                  if (campaign is Map && campaign['category'] != null)
                    _buildInfoRow(
                        Icons.label, 'Category', campaign['category'] ?? 'N/A'),
                  _buildInfoRow(Icons.business, 'NGO',
                      ngo is Map ? ngo['name'] ?? 'N/A' : 'N/A'),

                  // Message
                  if (donation['message'] != null &&
                      donation['message'].toString().isNotEmpty) ...[
                    const Divider(height: 24),
                    _buildSectionHeader('Donor Message'),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(
                        donation['message'],
                        style: const TextStyle(
                            fontStyle: FontStyle.italic, fontSize: 13),
                      ),
                    ),
                  ],

                  // 80G / Tax Info
                  if (donation['is80GEligible'] == true) ...[
                    const Divider(height: 24),
                    _buildSectionHeader('Tax Information'),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.receipt_long, '80G Eligible', 'Yes'),
                    if (donation['panNumber'] != null)
                      _buildInfoRow(
                          Icons.badge, 'PAN Number', donation['panNumber']),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: (50 * index).ms)
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.1);
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: AdminTheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: AdminTheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade500),
          const SizedBox(width: 8),
          Text('$label: ',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: color ?? Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
