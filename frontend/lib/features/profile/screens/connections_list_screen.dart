import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/app_services.dart';
import '../../../core/widgets/empty_state.dart';
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
        title: const Text('My Network'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryDark,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
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
                    ? const EmptyState(
                        icon: Icons.people_outline_rounded,
                        title: 'No connections yet',
                        description: 'Explore peers in the Connect tab with matching skills and connect with them.',
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
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => PublicProfileScreen(personId: peer.id)),
                                  ),
                                  child: CircleAvatar(
                                    backgroundColor: AppColors.softTeal,
                                    child: Text(peer.avatarInitials, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
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
                                        Text(peer.name, style: AppTextStyles.titleSmall),
                                        Text(peer.role, style: AppTextStyles.caption),
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
                                  ),
                                  child: const Text('Disconnect', style: AppTextStyles.labelSmall),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                // Pending Requests Tab
                pendingPeers.isEmpty
                    ? const EmptyState(
                        icon: Icons.mark_email_read_outlined,
                        title: 'No pending requests',
                        description: 'When other students send you connection requests, they will show up here.',
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        itemCount: pendingPeers.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final peer = pendingPeers[index];
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: AppColors.softBlue,
                                      child: Text(peer.avatarInitials, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(peer.name, style: AppTextStyles.titleSmall),
                                          Text('${peer.branch} · ${peer.year}', style: AppTextStyles.caption),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
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
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                        ),
                                        child: const Text('Decline'),
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
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                        ),
                                        child: const Text('Accept'),
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
