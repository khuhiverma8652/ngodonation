import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'donor/nearby_campaigns_screen.dart';
import 'donor/map_view_screen.dart';
import 'donor/today_campaigns_screen.dart';
import 'donor/donation_needs_screen.dart';
import 'donor/notifications_screen.dart';
import 'donor/local_impact_screen.dart';

class DonorDashboard extends StatefulWidget {
  const DonorDashboard({super.key});

  @override
  State<DonorDashboard> createState() => _DonorDashboardState();
}

class _DonorDashboardState extends State<DonorDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const NearbyCampaignsScreen(), // Screen 1: Nearby
    const MapViewScreen(), // Screen 2: Map View
    const TodayCampaignsScreen(), // Screen 3: Today
    DonationNeedsScreen(
      campaignId: "demo_id",
      campaignTitle: "Demo Campaign",
      targetAmount: 10000,
      raisedAmount: 2000,
    ),
    // Screen 4: Donation Needs
    const NotificationsScreen(), // Screen 5: Notifications
    const ImpactScreen(), // Screen 6: Your Impact
  ];

  final List<Map<String, dynamic>> _navItems = [
    {
      'icon': Icons.near_me,
      'activeIcon': Icons.near_me,
      'label': 'Nearby',
      'color': const Color(0xFF6200EE),
    },
    {
      'icon': Icons.map_outlined,
      'activeIcon': Icons.map,
      'label': 'Map',
      'color': const Color(0xFF00BCD4),
    },
    {
      'icon': Icons.today_outlined,
      'activeIcon': Icons.today,
      'label': 'Today',
      'color': const Color(0xFFFF5252),
    },
    {
      'icon': Icons.volunteer_activism_outlined,
      'activeIcon': Icons.volunteer_activism,
      'label': 'Donate',
      'color': const Color(0xFF9C27B0),
    },
    {
      'icon': Icons.notifications_none,
      'activeIcon': Icons.notifications,
      'label': 'Alerts',
      'color': const Color(0xFFFF9800),
    },
    {
      'icon': Icons.favorite_border,
      'activeIcon': Icons.favorite,
      'label': 'Impact',
      'color': const Color(0xFFE91E63),
    },
  ];

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
        body: _screens[_selectedIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(_navItems.length, (index) {
                  final item = _navItems[index];
                  final isSelected = _selectedIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedIndex = index);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? item['color'].withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected ? item['activeIcon'] : item['icon'],
                            color: isSelected
                                ? item['color']
                                : Colors.grey.shade600,
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['label'],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? item['color']
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate(
                          target: isSelected ? 1 : 0,
                        )
                        .scale(
                          duration: 200.ms,
                          begin: const Offset(1, 1),
                          end: const Offset(1.1, 1.1),
                        ),
                  );
                }),
              ),
            ),
          ),
        ),
        drawer: _buildDrawer(),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
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
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 30),

              // Profile Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 40,
                        color: Color(0xFF6200EE),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'John Doe',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Donor',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().scale(),

              const SizedBox(height: 20),

              // Menu Items
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    children: [
                      _buildDrawerItem(
                        icon: Icons.person_outline,
                        title: 'My Profile',
                        onTap: () {
                          // Navigate to profile
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.history,
                        title: 'Donation History',
                        onTap: () {
                          // Navigate to history
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.bookmark_outline,
                        title: 'Saved Campaigns',
                        onTap: () {
                          // Navigate to saved
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.receipt_long,
                        title: 'My Receipts',
                        onTap: () {
                          // Navigate to receipts
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.settings_outlined,
                        title: 'Settings',
                        onTap: () {
                          // Navigate to settings
                        },
                      ),
                      const Divider(height: 40),
                      _buildDrawerItem(
                        icon: Icons.help_outline,
                        title: 'Help & Support',
                        onTap: () {
                          // Navigate to help
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.info_outline,
                        title: 'About Us',
                        onTap: () {
                          // Navigate to about
                        },
                      ),
                      const Divider(height: 40),
                      _buildDrawerItem(
                        icon: Icons.logout,
                        title: 'Logout',
                        textColor: Colors.red,
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: textColor ?? const Color(0xFF6200EE),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
