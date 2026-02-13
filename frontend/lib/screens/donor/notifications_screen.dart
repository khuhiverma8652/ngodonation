import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';


class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'type': 'urgent',
      'icon': Icons.warning_amber,
      'color': const Color(0xFFFF5252),
      'title': 'Food drive starting near you in 2 hours',
      'subtitle': 'Andheri West • 3.2 km away',
      'time': '2h ago',
      'read': false,
    },
    {
      'type': 'volunteer',
      'icon': Icons.volunteer_activism,
      'color': const Color(0xFF00BCD4),
      'title': 'Short of volunteers today at Andheri',
      'subtitle': 'Medical Camp • 5 volunteers needed',
      'time': '4h ago',
      'read': false,
    },
    {
      'type': 'campaign',
      'icon': Icons.campaign,
      'color': const Color(0xFF9C27B0),
      'title': 'New education campaign near you',
      'subtitle': 'Goregaon East • Books donation needed',
      'time': '1d ago',
      'read': true,
    },
    {
      'type': 'success',
      'icon': Icons.check_circle,
      'color': const Color(0xFF4CAF50),
      'title': 'Your donation helped 50 families!',
      'subtitle': 'Food Distribution Campaign',
      'time': '2d ago',
      'read': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n['read']).length;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Smart Notifications',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF6200EE),
                      Color(0xFF3700B3),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.notifications_active,
                    size: 60,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
          ),

          // Info banner
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Only location-relevant notifications. No spam.',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  if (unreadCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5252),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$unreadCount new',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: -0.2),
          ),

          // Notifications list
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final notification = _notifications[index];
                  return _buildNotificationCard(notification, index);
                },
                childCount: _notifications.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Mark all as read
          setState(() {
            for (var notification in _notifications) {
              notification['read'] = true;
            }
          });
        },
        icon: const Icon(Icons.done_all),
        label: const Text('Mark all read'),
      ).animate(delay: 400.ms).fadeIn().scale(),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, int index) {
    final isRead = notification['read'] as bool;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : notification['color'].withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRead ? Colors.grey.shade200 : notification['color'].withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: isRead ? [] : [
          BoxShadow(
            color: notification['color'].withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: notification['color'].withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            notification['icon'],
            color: notification['color'],
            size: 28,
          ),
        ),
        title: Text(
          notification['title'],
          style: TextStyle(
            fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification['subtitle'],
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 12,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 4),
                Text(
                  notification['time'],
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
                if (!isRead) ...[
                  const Spacer(),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: notification['color'],
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        onTap: () {
          setState(() {
            notification['read'] = true;
          });
          // Handle notification tap
        },
      ),
    ).animate(delay: (100 * index).ms)
      .fadeIn(duration: 500.ms)
      .slideX(begin: -0.2, end: 0);
  }
}