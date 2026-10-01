import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/app_services.dart';
import '../widgets/person_card.dart';
import '../widgets/group_card.dart';
import '../widgets/mentor_card.dart';
import '../../home/screens/search_screen.dart';

/// Interactive Connect screen representing People, Groups & Mentors.
class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['All', 'Students', 'Groups', 'Mentors'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Connect & Network'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
            tooltip: 'Search People & Groups',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Segment Filter Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: List.generate(_filters.length, (index) {
                    final isSelected = _selectedFilterIndex == index;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedFilterIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.surface : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                            boxShadow: isSelected
                                ? const [
                                    BoxShadow(
                                      color: AppColors.shadow,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            _filters[index],
                            textAlign: TextAlign.center,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

            const Divider(height: 1),

            // Content List
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  // Students Section
                  if (_selectedFilterIndex == 0 || _selectedFilterIndex == 1) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Students & Peers', style: AppTextStyles.headlineSmall),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...AppServices.connect.allPeople.take(_selectedFilterIndex == 1 ? 50 : 3).map((peer) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: PersonCard(person: peer),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],

                  // Groups Section
                  if (_selectedFilterIndex == 0 || _selectedFilterIndex == 2) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Technical Communities', style: AppTextStyles.headlineSmall),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...AppServices.connect.allGroups.take(_selectedFilterIndex == 2 ? 50 : 3).map((grp) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GroupCard(group: grp),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],

                  // Mentors Section
                  if (_selectedFilterIndex == 0 || _selectedFilterIndex == 3) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Knowledge Mentors', style: AppTextStyles.headlineSmall),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...AppServices.connect.allMentors.take(_selectedFilterIndex == 3 ? 50 : 3).map((mentor) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: MentorCard(mentor: mentor),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
