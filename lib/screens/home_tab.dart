import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../theme/app_theme.dart';
import '../widgets/top_decor_blob.dart';
import 'board_screen.dart';
import 'create_board_screen.dart';
import 'task_detail_screen.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  void _showJoinBoardDialog(BuildContext context) {
    final TextEditingController codeCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Gabung Board',
            style: AppTextStyles.cardTitle.copyWith(fontSize: 18),
          ),
          content: TextField(
            controller: codeCtrl,
            style: AppTextStyles.inputText,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'Masukkan kode unik board...',
              hintStyle: AppTextStyles.cardSubtitle,
              filled: true,
              fillColor: AppColors.surfaceMuted,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Batal',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              onPressed: () {
                final code = codeCtrl.text.trim();
                if (code.isNotEmpty) {
                  final success = AppDataController.instance.joinBoardByCode(
                    code,
                  );
                  Navigator.pop(context);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Berhasil bergabung ke Board!'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Kode tidak valid atau Anda sudah bergabung.',
                        ),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              child: const Text('Gabung'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isManager =
        AppDataController.instance.currentUserRole == 'Pembuat Board';
    final profile = AppDataController.instance.currentUserProfile;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (isManager) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateBoardScreen(),
              ),
            );
          } else {
            _showJoinBoardDialog(context);
          }
        },
        backgroundColor: AppColors.primary,
        elevation: 3,
        shape: const CircleBorder(),
        child: Icon(
          isManager ? Icons.add : Icons.group_add_rounded,
          color: AppColors.textLight,
          size: 26,
        ),
      ),
      body: Stack(
        children: [
          TopDecorBlob(size: 150),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: AppSpacing.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Hello, ${profile['name']}',
                                style: AppTextStyles.screenTitle,
                              ),
                              const SizedBox(width: 6),
                              const Text('👋', style: TextStyle(fontSize: 22)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Keep going! You're on track.",
                            style: AppTextStyles.cardSubtitle,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.search_rounded,
                              color: AppColors.textPrimary,
                              size: 22,
                            ),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.notifications_none_rounded,
                              color: AppColors.textPrimary,
                              size: 22,
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _buildSectionHeader('My Boards', onViewAll: () {}),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 116,
                    child: ListenableBuilder(
                      listenable: AppDataController.instance,
                      builder: (context, _) {
                        final boards = AppDataController.instance.boards;

                        // Filter board khusus untuk 'Anggota' agar hanya melihat board yang ia ikuti
                        final visibleBoards = isManager
                            ? boards
                            : boards.where((b) {
                                final members = b['members'] as List? ?? [];
                                return members.any(
                                  (m) => m['name'] == profile['name'],
                                );
                              }).toList();

                        if (visibleBoards.isEmpty) {
                          return Center(
                            child: Text(
                              isManager
                                  ? 'Belum ada board. Buat baru!'
                                  : 'Anda belum bergabung ke board manapun.',
                              style: AppTextStyles.cardSubtitle,
                            ),
                          );
                        }
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: visibleBoards.length,
                          itemBuilder: (context, index) {
                            final b = visibleBoards[index];
                            final taskCount = AppDataController.instance.tasks
                                .where((t) => t['boardId'] == b['id'])
                                .length;
                            Color? boardColor;
                            if (b['color'] != null) {
                              boardColor = b['color'] is Color
                                  ? b['color'] as Color
                                  : Color(b['color'] as int);
                            }
                            return _buildBoardCard(
                              context,
                              boardId: b['id'],
                              title: b['title'] ?? 'Untitled Board',
                              taskCount: '$taskCount tasks',
                              icon:
                                  (b['icon'] as IconData?) ??
                                  Icons.folder_rounded,
                              iconBg:
                                  (b['iconBg'] as Color?) ??
                                  (boardColor?.withOpacity(0.15) ??
                                      AppColors.primarySurface),
                              iconColor:
                                  (b['iconColor'] as Color?) ??
                                  (boardColor ?? AppColors.primary),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionHeader("Today's Tasks", onViewAll: () {}),
                  const SizedBox(height: 12),
                  ListenableBuilder(
                    listenable: AppDataController.instance,
                    builder: (context, _) {
                      final todayTasks = AppDataController.instance.tasks
                          .where((t) => t['date'] == 'Today')
                          .toList();
                      if (todayTasks.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            'Semua tugas hari ini sudah beres!',
                            style: AppTextStyles.cardSubtitle,
                          ),
                        );
                      }
                      return Column(
                        children: todayTasks
                            .map((task) => _buildTaskItem(context, task: task))
                            .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  _buildSectionHeader('Recent Activity', onViewAll: () {}),
                  const SizedBox(height: 12),
                  ListenableBuilder(
                    listenable: AppDataController.instance,
                    builder: (context, _) {
                      final activities =
                          AppDataController.instance.recentActivities;
                      if (activities.isEmpty)
                        return Text(
                          'Belum ada aktivitas.',
                          style: AppTextStyles.cardSubtitle,
                        );
                      return Column(
                        children: activities
                            .map(
                              (act) => _buildActivityItem(
                                title: act['title'] ?? '',
                                time: act['time'] ?? '',
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {required VoidCallback onViewAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.sectionTitle),
        GestureDetector(
          onTap: onViewAll,
          child: Row(
            children: [
              Text('View all', style: AppTextStyles.sectionAction),
              const SizedBox(width: 2),
              Icon(Icons.chevron_right, size: 16, color: AppColors.textMuted),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBoardCard(
    BuildContext context, {
    required String boardId,
    required String title,
    required String taskCount,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                BoardScreen(boardId: boardId, boardTitle: title),
          ),
        );
      },
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.roundedLg,
          border: Border.all(color: AppColors.borderLight, width: 1.2),
          boxShadow: [AppShadows.card],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: AppRadius.roundedMd,
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  taskCount,
                  style: AppTextStyles.cardSubtitle.copyWith(fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(
    BuildContext context, {
    required Map<String, dynamic> task,
  }) {
    final priority = task['priority'] ?? 'Low';
    final isDone = task['isDone'] ?? false;
    final board = AppDataController.instance.boards.firstWhere(
      (b) => b['id'] == task['boardId'],
      orElse: () => {'title': 'Unknown'},
    );
    Color priorityBg = AppColors.priorityLowBg;
    Color priorityTextColor = AppColors.priorityLowText;
    if (priority == 'High') {
      priorityBg = AppColors.priorityHighBg;
      priorityTextColor = AppColors.priorityHighText;
    } else if (priority == 'Medium') {
      priorityBg = AppColors.priorityMediumBg;
      priorityTextColor = AppColors.priorityMediumText;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TaskDetailScreen(taskId: task['id']),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.roundedLg,
          border: Border.all(color: AppColors.borderLight, width: 1.2),
          boxShadow: [AppShadows.card],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () =>
                  AppDataController.instance.toggleTaskCompletion(task['id']),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isDone ? AppColors.primary : Colors.transparent,
                  borderRadius: AppRadius.roundedXs,
                  border: Border.all(
                    color: isDone ? AppColors.primary : AppColors.border,
                    width: 1.5,
                  ),
                ),
                child: isDone
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task['title'],
                    style: AppTextStyles.cardTitle.copyWith(
                      fontSize: 13,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      color: isDone
                          ? AppColors.textMuted
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${board['title']} • ${task['date']}',
                    style: AppTextStyles.cardSubtitle.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: priorityBg,
                borderRadius: AppRadius.roundedPill,
              ),
              child: Text(
                priority,
                style: AppTextStyles.badgeText.copyWith(
                  color: priorityTextColor,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem({required String title, required String time}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.roundedMd,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primarySurface,
            child: const Icon(
              Icons.person_rounded,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.cardTitle.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: AppTextStyles.cardSubtitle.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textMuted,
            size: 18,
          ),
        ],
      ),
    );
  }
}
