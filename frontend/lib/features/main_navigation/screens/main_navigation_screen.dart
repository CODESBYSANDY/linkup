import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../home/screens/home_screen.dart';
import '../../community/screens/community_screen.dart';
import '../../connect/screens/connect_screen.dart';
import '../../profile/screens/profile_screen.dart';

/// The main application shell managing bottom navigation across the 4 primary tabs:
/// 1. Home (Discovery & Opportunities)
/// 2. Community (Knowledge & Discussions)
/// 3. Connect (Students, Groups & Mentors)
/// 4. Profile (Student Professional Identity)
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    CommunityScreen(),
    ConnectScreen(),
    ProfileScreen(),
  ];

  void _onTabSelected(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(
              color: AppColors.border,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: _onTabSelected,
            backgroundColor: AppColors.surface,
            surfaceTintColor: Colors.transparent,
            indicatorColor: AppColors.softTeal,
            height: 64,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.explore_outlined, color: AppColors.textSecondary),
                selectedIcon: Icon(Icons.explore_rounded, color: AppColors.primaryDark),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.forum_outlined, color: AppColors.textSecondary),
                selectedIcon: Icon(Icons.forum_rounded, color: AppColors.primaryDark),
                label: 'Community',
              ),
              NavigationDestination(
                icon: Icon(Icons.people_outline_rounded, color: AppColors.textSecondary),
                selectedIcon: Icon(Icons.people_rounded, color: AppColors.primaryDark),
                label: 'Connect',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded, color: AppColors.textSecondary),
                selectedIcon: Icon(Icons.person_rounded, color: AppColors.primaryDark),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
