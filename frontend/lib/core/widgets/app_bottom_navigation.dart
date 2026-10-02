import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

/// Clean custom bottom navigation bar for LINKUP matching the reference images:
/// - Pure white elevated rounded container with 1px border and soft shadow
/// - 4 tabs: Home, Explore, Saved, Profile
/// - Vibrant purple active indicator with tinted icon background
/// - Muted slate inactive states
class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);

    return Container(
      decoration: BoxDecoration(
        color: navBg,
        border: Border(
          top: BorderSide(
            color: borderColor,
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.3) : const Color(0x080F172A),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                index: 0,
                label: 'Home',
                icon: Icons.home_rounded,
                selectedIcon: Icons.home_rounded,
              ),
              _buildNavItem(
                context: context,
                index: 1,
                label: 'Explore',
                icon: Icons.explore_outlined,
                selectedIcon: Icons.explore_rounded,
              ),
              _buildNavItem(
                context: context,
                index: 2,
                label: 'Saved',
                icon: Icons.bookmark_outline_rounded,
                selectedIcon: Icons.bookmark_rounded,
              ),
              _buildNavItem(
                context: context,
                index: 3,
                label: 'Profile',
                icon: Icons.person_outline_rounded,
                selectedIcon: Icons.person_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required String label,
    required IconData icon,
    required IconData selectedIcon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = currentIndex == index;
    final color = isSelected ? AppColors.primary : (isDark ? AppColors.darkTextMuted : const Color(0xFF94A3B8));
    final activeContainerBg = isDark
        ? AppColors.primary.withValues(alpha: 0.20)
        : const Color(0xFFF3E8FF);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(index),
          splashColor: AppColors.primary.withValues(alpha: 0.08),
          highlightColor: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                decoration: BoxDecoration(
                  color: isSelected ? activeContainerBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isSelected ? selectedIcon : icon,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: color,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
