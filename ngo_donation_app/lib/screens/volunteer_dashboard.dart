import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'volunteer/volunteer_home_screen.dart';
import 'volunteer/volunteer_progress_screen.dart';

class VolunteerDashboard extends StatefulWidget {
  const VolunteerDashboard({Key? key}) : super(key: key);

  @override
  State<VolunteerDashboard> createState() => _VolunteerDashboardState();
}

class _VolunteerDashboardState extends State<VolunteerDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const VolunteerHomeScreen(),      // What can I do today?
    const VolunteerProgressScreen(),  // Badge & Progress
  ];

  final List<Map<String, dynamic>> _navItems = [
    {
      'icon': Icons.volunteer_activism_outlined,
      'activeIcon': Icons.volunteer_activism,
      'label': 'Opportunities',
      'color': const Color(0xFF00BCD4),
    },
    {
      'icon': Icons.military_tech_outlined,
      'activeIcon': Icons.military_tech,
      'label': 'Progress',
      'color': const Color(0xFF9C27B0),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navItems.length, (index) {
                final item = _navItems[index];
                final isSelected = _selectedIndex == index;
                
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedIndex = index);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? item['color'].withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected ? item['activeIcon'] : item['icon'],
                            color: isSelected
                                ? item['color']
                                : Colors.grey.shade600,
                            size: 28,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item['label'],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected
                                  ? item['color']
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ).animate(
                      target: isSelected ? 1 : 0,
                    ).scale(
                      duration: 200.ms,
                      begin: const Offset(1, 1),
                      end: const Offset(1.05, 1.05),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
      drawer: _buildDrawer(),
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
              Color(0xFF00BCD4),
              Color(0xFF0097A7),
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
                        color: Color(0xFF00BCD4),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Jane Smith',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.military_tech,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Helper Badge',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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
                        title: 'My Activity',
                        onTap: () {
                          // Navigate to activity
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.emoji_events_outlined,
                        title: 'Achievements',
                        onTap: () {
                          // Navigate to achievements
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.leaderboard,
                        title: 'Leaderboard',
                        onTap: () {
                          // Navigate to leaderboard
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
        color: textColor ?? const Color(0xFF00BCD4),
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