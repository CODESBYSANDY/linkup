import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/app_services.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/riko_empty_state.dart';
import '../../../core/widgets/riko_expression.dart';
import '../widgets/person_card.dart';
import '../widgets/group_card.dart';
import '../widgets/mentor_card.dart';
import '../../home/screens/search_screen.dart';

/// Interactive Connect screen representing People, Groups & Mentors.
class ConnectScreen extends StatefulWidget {
  final bool showBackButton;

  const ConnectScreen({
    super.key,
    this.showBackButton = false,
  });

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['All', 'Students', 'Communities', 'Mentors'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: widget.showBackButton,
        title: Text(
          'Connect',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: AppColors.textPrimary),
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: List.generate(_filters.length, (index) {
                  final isSelected = _selectedFilterIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: AppChip(
                      label: _filters[index],
                      isSelected: isSelected,
                      onSelected: () => setState(() => _selectedFilterIndex = index),
                    ),
                  );
                }),
              ),
            ),

            const Divider(height: 1, color: AppColors.borderSubtle),

            // Content List
            Expanded(
              child: ListenableBuilder(
                listenable: AppServices.connect,
                builder: (context, _) {
                  final people = AppServices.connect.allPeople;
                  final groups = AppServices.connect.allGroups;
                  final mentors = AppServices.connect.allMentors;

                  final hasPeople = people.isNotEmpty;
                  final hasGroups = groups.isNotEmpty;
                  final hasMentors = mentors.isNotEmpty;

                  if (_selectedFilterIndex == 1 && !hasPeople) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        await AppServices.connect.refresh();
                      },
                      color: AppColors.primaryBright,
                      backgroundColor: AppColors.surface,
                      child: ListView(
                        children: const [
                          SizedBox(height: 60),
                          RikoEmptyState(
                            expression: RikoExpression.waving,
                            title: 'No peers found',
                            message: 'Start building your network as new students join LINKUP.',
                          ),
                        ],
                      ),
                    );
                  }

                  if (_selectedFilterIndex == 2 && !hasGroups) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        await AppServices.connect.refresh();
                      },
                      color: AppColors.primaryBright,
                      backgroundColor: AppColors.surface,
                      child: ListView(
                        children: const [
                          SizedBox(height: 60),
                          RikoEmptyState(
                            expression: RikoExpression.excited,
                            title: 'No communities yet',
                            message: 'Technical groups and interest clubs will appear here.',
                          ),
                        ],
                      ),
                    );
                  }

                  if (_selectedFilterIndex == 3 && !hasMentors) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        await AppServices.connect.refresh();
                      },
                      color: AppColors.primaryBright,
                      backgroundColor: AppColors.surface,
                      child: ListView(
                        children: const [
                          SizedBox(height: 60),
                          RikoEmptyState(
                            expression: RikoExpression.usingTablet,
                            title: 'No mentors right now',
                            message: 'Verified alumni and industry mentors will be listed here.',
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      await AppServices.connect.refresh();
                    },
                    color: AppColors.primaryBright,
                    backgroundColor: AppColors.surface,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      children: [
                        // Students Section
                        if ((_selectedFilterIndex == 0 || _selectedFilterIndex == 1) && hasPeople) ...[
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Students & Peers', style: AppTextStyles.headlineSmall),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ...people.take(_selectedFilterIndex == 1 ? 50 : 3).map((peer) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: PersonCard(person: peer),
                            );
                          }),
                          const SizedBox(height: 16),
                        ],

                        // Groups Section
                        if ((_selectedFilterIndex == 0 || _selectedFilterIndex == 2) && hasGroups) ...[
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Technical Communities', style: AppTextStyles.headlineSmall),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ...groups.take(_selectedFilterIndex == 2 ? 50 : 3).map((grp) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GroupCard(group: grp),
                            );
                          }),
                          const SizedBox(height: 16),
                        ],

                        // Mentors Section
                        if ((_selectedFilterIndex == 0 || _selectedFilterIndex == 3) && hasMentors) ...[
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Knowledge Mentors', style: AppTextStyles.headlineSmall),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ...mentors.take(_selectedFilterIndex == 3 ? 50 : 3).map((mentor) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: MentorCard(mentor: mentor),
                            );
                          }),
                          const SizedBox(height: 16),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
