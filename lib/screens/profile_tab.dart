import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../theme/app_theme.dart';
import '../widgets/top_decor_blob.dart';
import 'sign_in_screen.dart';
import 'settings/my_boards_screen.dart';
import 'settings/account_settings_screen.dart';
import 'settings/appearance_screen.dart';
import 'settings/help_support_screen.dart';
import 'settings/about_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          TopDecorBlob(size: 150),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: AppSpacing.screenPadding,
              child: ListenableBuilder(
                listenable: AppDataController.instance,
                builder: (context, _) {
                  // MENGAMBIL DATA GLOBAL
                  final profile = AppDataController.instance.currentUserProfile;
                  final boards = AppDataController.instance.boards;
                  final tasks = AppDataController.instance.tasks;

                  final totalBoards = boards.length.toString();
                  final totalTasks = tasks.length.toString();

                  // Kalkulasi anggota tim unik dari semua board yang diikuti
                  final Set<String> uniqueMembers = {};
                  for (var board in boards) {
                    final members = board['members'] as List? ?? [];
                    for (var member in members) {
                      uniqueMembers.add(member['name'] as String);
                    }
                  }
                  final totalMembers = uniqueMembers.length.toString();

                  final Color avatarColor = Color(profile['avatarColor']);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Profile', style: AppTextStyles.screenTitle),
                          IconButton(
                            icon: Icon(
                              Icons.settings_outlined,
                              color: AppColors.textPrimary,
                              size: 22,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AccountSettingsScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // User Info Header Dinamis
                      Row(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: avatarColor.withOpacity(0.15),
                              border: Border.all(
                                color: avatarColor.withOpacity(0.4),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                profile['initials'],
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: avatarColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile['name'],
                                style: AppTextStyles.screenTitle.copyWith(
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                profile['email'],
                                style: AppTextStyles.cardSubtitle.copyWith(
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const AccountSettingsScreen(),
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    Text(
                                      'Edit Profile',
                                      style: AppTextStyles.linkText.copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      size: 14,
                                      color: AppColors.primary,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Stats Box Dinamis
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurfaceSubtle,
                          borderRadius: AppRadius.roundedLg,
                          border: Border.all(
                            color: AppColors.primaryContainer,
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatItem(totalBoards, 'Boards'),
                            Container(
                              height: 28,
                              width: 1,
                              color: AppColors.primaryContainer,
                            ),
                            _buildStatItem(totalTasks, 'Tasks'),
                            Container(
                              height: 28,
                              width: 1,
                              color: AppColors.primaryContainer,
                            ),
                            _buildStatItem(totalMembers, 'Members'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Menu Options List
                      _buildMenuItem(
                        Icons.auto_awesome_mosaic_outlined,
                        'My Boards',
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MyBoardsScreen(),
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(
                        Icons.settings_outlined,
                        'Account Settings',
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AccountSettingsScreen(),
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(Icons.palette_outlined, 'Appearance', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AppearanceScreen(),
                          ),
                        );
                      }),
                      _buildMenuItem(
                        Icons.help_outline_rounded,
                        'Help & Support',
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HelpSupportScreen(),
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(Icons.info_outline_rounded, 'About', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AboutScreen(),
                          ),
                        );
                      }),
                      const SizedBox(height: 12),

                      // Log Out Button
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: AppRadius.roundedMd,
                          border: Border.all(
                            color: AppColors.borderLight,
                            width: 1.2,
                          ),
                        ),
                        child: ListTile(
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const SignInScreen(),
                              ),
                            );
                          },
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppRadius.roundedMd,
                          ),
                          leading: const Icon(
                            Icons.logout_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                          title: Text(
                            'Log Out',
                            style: AppTextStyles.cardTitle.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textMuted,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(count, style: AppTextStyles.statNumber),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.statLabel),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.roundedMd,
        border: Border.all(color: AppColors.borderLight, width: 1.2),
      ),
      child: ListTile(
        onTap: onTap,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedMd),
        leading: Icon(icon, color: AppColors.textPrimary, size: 22),
        title: Text(
          title,
          style: AppTextStyles.cardTitle.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textMuted,
          size: 18,
        ),
      ),
    );
  }
}
