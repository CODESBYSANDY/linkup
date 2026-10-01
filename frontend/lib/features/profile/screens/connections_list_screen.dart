import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/app_services.dart';
import '../../../core/widgets/riko_empty_state.dart';
import '../../../core/widgets/riko_expression.dart';
import 'public_profile_screen.dart';

/// Screen displaying the student's connections and incoming pending requests.
class ConnectionsListScreen extends StatefulWidget {
  const ConnectionsListScreen({super.key});

  @override
  State<ConnectionsListScreen> createState() => _ConnectionsListScreenState();
}

class _ConnectionsListScreenState extends State<ConnectionsListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Network',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primaryBright,
          indicatorWeight: 3,
          labelStyle: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700),
          unselectedLabelStyle: AppTextStyles.labelMedium,
          tabs: const [
            Tab(text: 'Connections'),
            Tab(text: 'Pending Requests'),
          ],
        ),
      ),
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: AppServices.auth.userNotifier,
          builder: (context, user, _) {
            final connectedIds = user?.connectedUserIds ?? [];
            final pendingIds = user?.pendingConnectionIds ?? [];

            final connectedPeers = AppServices.connect.allPeople
                .where((p) => connectedIds.contains(p.id))
                .toList();

            final pendingPeers = AppServices.connect.allPeople
                .where((p) => pendingIds.contains(p.id))
                .toList();

            return TabBarView(
              controller: _tabController,
              children: [
                // Connections Tab
                connectedPeers.isEmpty
                    ? const RikoEmptyState(
                        expression: RikoExpression.waving,
                        title: 'No connections yet',
                        message: 'Explore student builders in the Connect tab to expand your tech network.',
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        itemCount: connectedPeers.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final peer = connectedPeers[index];
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: AppRadii.cardRadius,
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => PublicProfileScreen(personId: peer.id)),
                                  ),
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      peer.avatarInitials,
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryLight),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => PublicProfileScreen(personId: peer.id)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(peer.name, style: AppTextStyles.titleMedium),
                                        const SizedBox(height: 2),
                                        Text(peer.role, style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
                                      ],
                                    ),
                                  ),
                                ),
                                OutlinedButton(
                                  onPressed: () async {
                                    await AppServices.auth.toggleConnectUser(peer.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Removed ${peer.name} from connections')),
                                      );
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    minimumSize: Size.zero,
                                    side: const BorderSide(color: AppColors.border),
                                  ),
                                  child: Text('Disconnect', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                // Pending Requests Tab
                pendingPeers.isEmpty
                    ? const RikoEmptyState(
                        expression: RikoExpression.sleeping,
                        title: 'No pending requests',
                        message: 'When other students send you connection requests, they will show up here.',
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        itemCount: pendingPeers.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final peer = pendingPeers[index];
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: AppRadii.cardRadius,
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary.withValues(alpha: 0.18),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        peer.avatarInitials,
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondaryLight),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(peer.name, style: AppTextStyles.titleMedium),
                                          const SizedBox(height: 2),
                                          Text('${peer.branch} · ${peer.year}', style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () async {
                                          await AppServices.auth.toggleConnectUser(peer.id);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Request declined')),
                                            );
                                          }
                                        },
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          side: const BorderSide(color: AppColors.border),
                                        ),
                                        child: Text('Decline', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textMuted)),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          await AppServices.auth.toggleConnectUser(peer.id);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Connected with ${peer.name}! 🎉')),
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                        ),
                                        child: const Text('Accept', style: TextStyle(fontWeight: FontWeight.w700)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ],
            );
          },
        ),
      ),
    );
  }
}
