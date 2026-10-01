import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/app_services.dart';
import '../../community/widgets/post_card.dart';
import '../../community/screens/create_post_screen.dart';

/// Screen displaying community group details, discussions feed, and resources.
class GroupDetailScreen extends StatefulWidget {
  final String groupId;

  const GroupDetailScreen({
    super.key,
    required this.groupId,
  });

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final group = AppServices.connect.getGroupById(widget.groupId);

    if (group == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Group not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(group.name),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CreatePostScreen(
                initialGroupId: group.id,
                initialGroupName: group.name,
              ),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textInverse,
        icon: const Icon(Icons.add_comment_rounded),
        label: const Text('Start Discussion', style: AppTextStyles.labelLarge),
      ),
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppColors.softTeal,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.groups_rounded, color: AppColors.primaryDark, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(group.name, style: AppTextStyles.headlineSmall),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${group.membersCount} student members · ${group.category}',
                                    style: AppTextStyles.caption.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(group.description, style: AppTextStyles.bodyMedium),
                        const SizedBox(height: 16),
                        ValueListenableBuilder(
                          valueListenable: AppServices.auth.userNotifier,
                          builder: (context, user, _) {
                            final isJoined = user?.joinedGroupIds.contains(group.id) ?? false;
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final joined = await AppServices.auth.toggleJoinGroup(group.id);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).clearSnackBars();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(joined ? 'Joined ${group.name}!' : 'Left ${group.name}'),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  }
                                },
                                icon: Icon(isJoined ? Icons.check_circle_rounded : Icons.group_add_rounded, size: 18),
                                label: Text(isJoined ? 'Joined Community' : 'Join Community'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isJoined ? AppColors.softTeal : AppColors.primary,
                                  foregroundColor: isJoined ? AppColors.primaryDark : AppColors.textInverse,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverTabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primaryDark,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: 'Discussions'),
                      Tab(text: 'Resources'),
                      Tab(text: 'Events'),
                      Tab(text: 'Rules'),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              // Discussions Tab
              ValueListenableBuilder(
                valueListenable: AppServices.community.postsNotifier,
                builder: (context, posts, _) {
                  final groupPosts = posts.where((p) => p.groupId == group.id || p.tags.any((t) => group.name.toLowerCase().contains(t.toLowerCase()))).toList();

                  final displayPosts = groupPosts.isNotEmpty ? groupPosts : posts.take(3).toList();

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    itemCount: displayPosts.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, idx) => PostCard(post: displayPosts[idx]),
                  );
                },
              ),

              // Resources Tab
              ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: group.resources.map((res) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.description_outlined, color: AppColors.primary, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(res, style: AppTextStyles.titleSmall),
                          ),
                          const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.textTertiary),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              // Events Tab
              ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: group.events.map((ev) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.event_available_rounded, color: AppColors.secondary, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(ev, style: AppTextStyles.titleSmall),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              // Rules Tab
              ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: group.rules.map((rule) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.shield_outlined, color: AppColors.textSecondary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(child: Text(rule, style: AppTextStyles.bodySmall)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.background,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}
