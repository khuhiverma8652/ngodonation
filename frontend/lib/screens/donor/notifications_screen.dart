import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:ngo_donation_app/services/api_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = true;
  List<dynamic> _notifications = [];
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      final response = await ApiService.getNotifications();
      if (response['success'] == true) {
        setState(() {
          _notifications = response['notifications'] ?? [];
          _unreadCount = response['unreadCount'] ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markRead(String id) async {
    try {
      await ApiService.markNotificationRead(id);
      _fetchNotifications(); // Refresh
    } catch (e) {
      debugPrint("Error marking notification read: $e");
    }
  }

  Future<void> _markAllRead() async {
    try {
      await ApiService.markAllNotificationsRead();
      _fetchNotifications(); // Refresh
    } catch (e) {
      debugPrint("Error marking all read: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchNotifications,
              child: CustomScrollView(
                slivers: [
                  // Beautiful Custom AppBar
                  SliverAppBar(
                    expandedHeight: 180,
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
                            colors: [Color(0xFF6200EE), Color(0xFF3700B3)],
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.notifications_active,
                            size: 80,
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                      ),
                    ),
                    actions: [
                      if (_unreadCount > 0)
                        TextButton(
                          onPressed: _markAllRead,
                          child: const Text(
                            'Mark all read',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),

                  // Info Banner
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.blue),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Only location-relevant notifications. No spam.',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ),
                          if (_unreadCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF5252),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$_unreadCount NEW',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Notifications List
                  if (_notifications.isEmpty)
                    const SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_none,
                                size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text("All caught up!",
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
                            final notification = _notifications[index];
                            return _buildNotificationCard(notification, index);
                          },
                          childCount: _notifications.length,
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, int index) {
    final bool isRead = notification['read'] ?? false;
    final String type = notification['type'] ?? 'info';
    final String title = notification['title'] ?? 'Notification';
    final String message = notification['message'] ?? '';
    final DateTime createdAt =
        DateTime.tryParse(notification['createdAt'] ?? '') ?? DateTime.now();

    final Color color = _getNotificationColor(type);
    final IconData icon = _getNotificationIcon(type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : color.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRead ? Colors.grey.shade200 : color.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: () {
          if (!isRead) _markRead(notification['_id']);
        },
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
            fontSize: 15,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(
              message,
              style: TextStyle(
                  color: Colors.grey.shade600, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 12, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text(
                  _formatTime(createdAt),
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                ),
                const Spacer(),
                if (!isRead)
                  Container(
                    width: 8,
                    height: 8,
                    decoration:
                        BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
              ],
            ),
          ],
        ),
      ),
    ).animate(delay: (index * 50).ms).fadeIn().slideX(begin: 0.1);
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    return DateFormat('dd MMM').format(dt);
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'urgent':
        return const Color(0xFFFF5252);
      case 'volunteer':
        return const Color(0xFF00BCD4);
      case 'campaign':
        return const Color(0xFF9C27B0);
      case 'success':
        return const Color(0xFF4CAF50);
      case 'donation':
        return const Color(0xFF6200EE);
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'urgent':
        return Icons.warning_amber_rounded;
      case 'volunteer':
        return Icons.volunteer_activism_rounded;
      case 'campaign':
        return Icons.campaign_rounded;
      case 'success':
        return Icons.check_circle_rounded;
      case 'donation':
        return Icons.payments_rounded;
      default:
        return Icons.info_rounded;
    }
  }
}
