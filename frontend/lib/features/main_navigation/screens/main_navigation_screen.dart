import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/app_bottom_navigation.dart';
import '../../home/screens/home_screen.dart';
import '../../opportunities/screens/explore_screen.dart';
import '../../opportunities/screens/saved_opportunities_screen.dart';
import '../../profile/screens/profile_screen.dart';

/// The main application shell managing bottom navigation across the 4 primary tabs:
/// 1. Home (Discovery & Opportunities Hero)
/// 2. Explore (Full Search & Category Discovery)
/// 3. Saved (Bookmarked Opportunities & Library)
/// 4. Profile (Student Professional Identity)
class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    HomeScreen(),
    ExploreScreen(),
    SavedOpportunitiesScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

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
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
