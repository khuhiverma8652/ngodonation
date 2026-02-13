import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme_enhanced.dart';

class CampaignCard extends StatelessWidget {
  final Map<String, dynamic> campaign;
  final VoidCallback? onView;
  final VoidCallback? onSupport;
  final VoidCallback? onDonate;
  final VoidCallback? onVolunteer;

  const CampaignCard({
    Key? key,
    required this.campaign,
    this.onView,
    this.onSupport,
    this.onDonate,
    this.onVolunteer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final category = campaign['category'] ?? 'Other';
    final liveStatus = campaign['liveStatus'] ?? 'upcoming';
    final fundingPercentage = campaign['fundingPercentage'] ?? 0;
    final distance = campaign['distance'] ?? 0.0;
    final is80G = campaign['is80GEligible'] ?? false;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onView,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with gradient and status badge
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: AppTheme.getCategoryGradient(category),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Stack(
                children: [
                  // Category icon
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: Icon(
                      _getCategoryIcon(category),
                      size: 60,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  
                  // Top badges
                  Positioned(
                    top: 12,
                    left: 12,
                    right: 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Status badge
                        _buildStatusBadge(liveStatus),
                        
                        // 80G badge
                        if (is80G)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.verified,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '80G',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn().scale(),
                      ],
                    ),
                  ),
                  
                  // Category label
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getCategoryIcon(category),
                            size: 16,
                            color: AppTheme.getCategoryColor(category),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            category,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.getCategoryColor(category),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // NGO Name
                  Text(
                    campaign['ngoId']?['name'] ?? 'NGO',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  
                  // Campaign Title
                  Text(
                    campaign['title'] ?? '',
                    style: AppTheme.heading3,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  
                  // Why this matters
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            campaign['whyMatters'] ?? '',
                            style: AppTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Date, Time, Distance
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatDate(campaign['startDate']),
                        style: AppTheme.bodySmall,
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatTime(campaign['startDate']),
                        style: AppTheme.bodySmall,
                      ),
                      const Spacer(),
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${distance.toStringAsFixed(1)} km',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Funding Progress
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₹${_formatAmount(campaign['currentAmount'] ?? 0)}',
                            style: AppTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'of ₹${_formatAmount(campaign['targetAmount'] ?? 0)}',
                            style: AppTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: fundingPercentage / 100,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.getCategoryColor(category),
                          ),
                          minHeight: 8,
                        ),
                      ).animate().fadeIn().slideX(),
                      const SizedBox(height: 6),
                      Text(
                        '$fundingPercentage% funded',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.getCategoryColor(category),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onView,
                          icon: const Icon(Icons.remove_red_eye, size: 18),
                          label: const Text('View'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: onSupport,
                        icon: const Icon(Icons.favorite_border),
                        color: AppTheme.error,
                        tooltip: 'Support',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onDonate,
                          icon: const Icon(Icons.currency_rupee, size: 18),
                          label: const Text('Donate'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.getCategoryColor(category),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ).animate().fadeIn(delay: 100.ms).slideX(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onVolunteer,
                          icon: const Icon(Icons.volunteer_activism, size: 18),
                          label: const Text('Volunteer'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(
                              color: AppTheme.getCategoryColor(category),
                              width: 2,
                            ),
                            foregroundColor: AppTheme.getCategoryColor(category),
                          ),
                        ).animate().fadeIn(delay: 200.ms).slideX(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.2, duration: 300.ms);
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;
    String text;

    switch (status.toLowerCase()) {
      case 'live':
        color = AppTheme.liveColor;
        icon = Icons.circle;
        text = 'LIVE';
        break;
      case 'upcoming':
        color = AppTheme.upcomingColor;
        icon = Icons.schedule;
        text = 'UPCOMING';
        break;
      case 'completed':
        color = AppTheme.completedColor;
        icon = Icons.check_circle;
        text = 'COMPLETED';
        break;
      default:
        color = Colors.grey;
        icon = Icons.info;
        text = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTheme.bodySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale();
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

  String _formatDate(dynamic date) {
    if (date == null) return '';
    final DateTime dateTime = DateTime.parse(date.toString());
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]}';
  }

  String _formatTime(dynamic date) {
    if (date == null) return '';
    final DateTime dateTime = DateTime.parse(date.toString());
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  String _formatAmount(dynamic amount) {
    if (amount == null) return '0';
    final value = double.parse(amount.toString());
    if (value >= 10000000) {
      return '${(value / 10000000).toStringAsFixed(1)}Cr';
    } else if (value >= 100000) {
      return '${(value / 100000).toStringAsFixed(1)}L';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }
}