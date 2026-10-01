import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../core/services/app_services.dart';
import '../../../core/widgets/app_background.dart';
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
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(
          child: Text('Group not found', style: AppTextStyles.bodyMedium),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(group.name, style: AppTextStyles.headlineSmall),
        centerTitle: false,
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppShadows.purpleGlow,
        ),
        child: FloatingActionButton.extended(
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
          backgroundColor: AppColors.primaryBright,
          foregroundColor: AppColors.textInverse,
          icon: const Icon(Icons.add_comment_rounded, size: 20),
          label: const Text('Start Discussion', style: AppTextStyles.labelLarge),
        ),
      ),
      body: AppBackground(
        showGlows: true,
        child: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.cardBorder),
                        boxShadow: AppShadows.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: AppColors.purpleGradient,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: AppShadows.purpleGlow,
                                ),
                                child: const Icon(
                                  Icons.groups_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      group.name,
                                      style: AppTextStyles.headlineSmall.copyWith(
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withValues(alpha: 0.18),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: AppColors.primary.withValues(alpha: 0.3),
                                            ),
                                          ),
                                          child: Text(
                                            group.category,
                                            style: AppTextStyles.caption.copyWith(
                                              color: AppColors.lavender,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${group.membersCount} members',
                                          style: AppTextStyles.caption.copyWith(
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            group.description,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 18),
                          ValueListenableBuilder(
                            valueListenable: AppServices.auth.userNotifier,
                            builder: (context, user, _) {
                              final isJoined = user?.joinedGroupIds.contains(group.id) ?? false;
                              return SizedBox(
                                width: double.infinity,
                                height: 46,
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    final joined = await AppServices.auth.toggleJoinGroup(group.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).clearSnackBars();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          backgroundColor: AppColors.surfaceElevated,
                                          content: Text(
                                            joined ? 'Joined ${group.name}!' : 'Left ${group.name}',
                                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
                                          ),
                                          duration: const Duration(seconds: 1),
                                        ),
                                      );
                                    }
                                  },
                                  icon: Icon(
                                    isJoined ? Icons.check_circle_rounded : Icons.group_add_rounded,
                                    size: 18,
                                  ),
                                  label: Text(isJoined ? 'Joined Community' : 'Join Community'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isJoined ? AppColors.surfaceElevated : AppColors.primaryBright,
                                    foregroundColor: isJoined ? AppColors.lavender : AppColors.textInverse,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      side: isJoined
                                          ? BorderSide(color: AppColors.cardBorder)
                                          : BorderSide.none,
                                    ),
                                    elevation: isJoined ? 0 : 2,
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
                      labelColor: AppColors.primaryBright,
                      unselectedLabelColor: AppColors.textMuted,
                      indicatorColor: AppColors.primaryBright,
                      indicatorWeight: 3,
                      labelStyle: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
                      unselectedLabelStyle: AppTextStyles.labelLarge,
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
                    final groupPosts = posts
                        .where((p) =>
                            p.groupId == group.id ||
                            p.tags.any((t) => group.name.toLowerCase().contains(t.toLowerCase())))
                        .toList();

                    final displayPosts = groupPosts.isNotEmpty ? groupPosts : posts.take(3).toList();

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      itemCount: displayPosts.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 14),
                      itemBuilder: (context, idx) => PostCard(post: displayPosts[idx]),
                    );
                  },
                ),

                // Resources Tab
                ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  children: group.resources.map((res) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.description_outlined, color: AppColors.primaryBright, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(res, style: AppTextStyles.titleMedium),
                            ),
                            const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.textMuted),
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
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.electricBlue.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.event_available_rounded, color: AppColors.electricBlue, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(ev, style: AppTextStyles.titleMedium),
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
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.shield_outlined, color: AppColors.lavender, size: 18),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                rule,
                                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.4),
                              ),
                            ),
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
