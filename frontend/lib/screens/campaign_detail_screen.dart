import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class CampaignDetailScreen extends StatelessWidget {
  final Map<String, dynamic> campaign;

  const CampaignDetailScreen({required this.campaign, super.key});

  @override
  Widget build(BuildContext context) {
    final title = campaign['title'] ?? 'Untitled Campaign';
    final description = campaign['description'] ?? 'No description provided';
    final category = campaign['category'] ?? 'General';
    final target = (campaign['targetAmount'] ?? 0).toDouble();
    final raised = (campaign['currentAmount'] ?? 0).toDouble();
    final ngoName = campaign['ngoId']?['name'] ?? 'Helping Hands NGO';
    final startDate = DateTime.parse(campaign['startDate']);
    final endDate = DateTime.parse(campaign['endDate']);
    final area = campaign['location']?['area'] ?? campaign['area'] ?? 'Various';
    final city = campaign['location']?['city'] ?? 'Mumbai';

    final progress = target > 0 ? (raised / target) : 0.0;
    final primaryColor = _getCategoryColor(category);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header with Image/Gradient
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            actions: [
              IconButton(
                onPressed: () {
                  Share.share(
                      'Check out this campaign: $title\n\n$description\n\nSupport here: https://ngodonation.app/campaign/${campaign['_id'] ?? ''}');
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share, color: Colors.white, size: 20),
                ),
                tooltip: 'Share Campaign',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withOpacity(0.6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(_getCategoryIcon(category),
                      size: 100, color: Colors.white.withOpacity(0.3)),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // NGO & Category Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          category.toUpperCase(),
                          style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.business,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(ngoName,
                              style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Funding Status
                  const Text("Funding Required",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "₹${NumberFormat('#,##,###').format(raised)} Raised",
                        style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                      Text(
                        "Goal: ₹${NumberFormat('#,##,###').format(target)}",
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 12,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${(progress * 100).toStringAsFixed(1)}% Completed",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const Divider(height: 48),

                  // Dates & Location
                  const Text("Campaign Information",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.calendar_today, "Duration",
                      "${DateFormat('MMM d, yyyy').format(startDate)} - ${DateFormat('MMM d, yyyy').format(endDate)}"),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.location_on, "Location", "$area, $city"),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.info_outline, "Purpose",
                      campaign['purpose'] ?? "Community Welfare"),
                  const Divider(height: 48),

                  // Story/Description
                  const Text("The Story",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: const TextStyle(
                        fontSize: 14, height: 1.6, color: Colors.black87),
                  ),
                  const SizedBox(height: 32),

                  // Item Needs
                  if (campaign['needs'] != null &&
                      (campaign['needs'] as List).isNotEmpty) ...[
                    const Text("Required Items",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ...(campaign['needs'] as List).map((need) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.inventory_2_outlined,
                                  color: primaryColor, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: Text(need['item'] ?? 'Requirement',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500))),
                              Text("Qty: ${need['quantity']}",
                                  style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )),
                  ],
                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5))
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/payment', arguments: campaign);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text("SUPPORT THIS CAUSE",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 20, color: Colors.blue.shade700),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ),
      ],
    );
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
        return Icons.emergency;
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
