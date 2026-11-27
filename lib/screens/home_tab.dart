import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../theme/app_theme.dart';
import '../widgets/top_decor_blob.dart';
import 'board_screen.dart';
import 'create_board_screen.dart';
import 'task_detail_screen.dart';

class HomeTab extends StatelessWidget {
  HomeTab({super.key});

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
              onPressed: () async {
                final code = codeCtrl.text.trim();
                if (code.isNotEmpty) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Memeriksa kode board...'),
                      duration: Duration(seconds: 1),
                    ),
                  );

                  final result = await AppDataController.instance.joinBoardByCode(
                    code,
                  );

                  if (!context.mounted) return;

                  if (result['success'] == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Berhasil bergabung ke Board!'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          result['message'] ??
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

  List _getVisibleBoards(
    bool isManager,
    Map<dynamic, dynamic> profile,
  ) {
    final boards = AppDataController.instance.boards;
    if (isManager) return boards;

    final myId = profile['id']?.toString() ?? '';
    final myName = profile['name']?.toString() ?? '';

    return boards.where((b) {
      final members = b['members'] as List? ?? [];
      return members.any(
        (m) =>
            (myId.isNotEmpty && m['userId']?.toString() == myId) ||
            (myName.isNotEmpty && m['name']?.toString() == myName),
      );
    }).toList();
  }

  void _showAllBoardsModal(
    BuildContext context,
    List visibleBoards,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Semua Board (${visibleBoards.length})',
                  style: AppTextStyles.screenTitle.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.55,
                  ),
                  child: visibleBoards.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'Belum ada board tersedia.',
                              style: AppTextStyles.cardSubtitle,
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: visibleBoards.length,
                          itemBuilder: (context, index) {
                            final b = visibleBoards[index];
                            final title =
                                b['title']?.toString() ?? 'Untitled Board';
                            final taskCount = AppDataController.instance.tasks
                                .where((t) => t['boardId'] == b['id'])
                                .length;
                            Color boardColor = AppColors.primary;
                            if (b['color'] != null) {
                              boardColor = b['color'] is Color
                                  ? b['color'] as Color
                                  : Color(b['color'] as int);
                            }
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: boardColor.withOpacity(0.15),
                                  borderRadius: AppRadius.roundedMd,
                                ),
                                child: Icon(
                                  (b['icon'] as IconData?) ??
                                      Icons.folder_rounded,
                                  color: boardColor,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                title,
                                style: AppTextStyles.cardTitle.copyWith(
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                '$taskCount tasks',
                                style: AppTextStyles.cardSubtitle.copyWith(
                                  fontSize: 12,
                                ),
                              ),
                              trailing: Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.textMuted,
                              ),
                              onTap: () {
                                Navigator.pop(ctx);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BoardScreen(
                                      boardId: b['id'].toString(),
                                      boardTitle: title,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAllActivitiesModal(
    BuildContext context,
    List activities,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Semua Aktivitas Terbaru',
                  style: AppTextStyles.screenTitle.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.6,
                  ),
                  child: activities.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'Belum ada aktivitas tercatat.',
                              style: AppTextStyles.cardSubtitle,
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: activities.length,
                          itemBuilder: (context, index) {
                            final act = activities[index];
                            return _buildActivityItem(
                              context,
                              activity: act,
                              closeModalFirst: true,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleActivityTap(
    BuildContext context,
    Map<String, dynamic> activity, {
    bool closeModalFirst = false,
  }) {
    final String? targetId = activity['targetId']?.toString();
    final String? boardId = activity['boardId']?.toString();

    if (closeModalFirst && Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    if (targetId != null && targetId.isNotEmpty) {
      final taskExists = AppDataController.instance.tasks.any(
        (t) => t['id']?.toString() == targetId,
      );
      if (taskExists) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TaskDetailScreen(taskId: targetId),
          ),
        );
        return;
      }
    }

    if (boardId != null && boardId.isNotEmpty) {
      final board = AppDataController.instance.boards.firstWhere(
        (b) => b['id']?.toString() == boardId,
        orElse: () => <String, dynamic>{},
      );
      if (board.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BoardScreen(
              boardId: boardId,
              boardTitle: board['title']?.toString() ?? 'Board',
            ),
          ),
        );
      }
    }
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
      body: RefreshIndicator(
        onRefresh: () async {
          final userId = AppDataController.instance.currentUserProfile['id'];
          if (userId != null && userId.toString().isNotEmpty) {
            await AppDataController.instance.loadUserBoards(userId.toString());
            await AppDataController.instance.refreshNotifications();
          }
        },
        child: Stack(
          children: [
            TopDecorBlob(size: 150),
            SafeArea(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: AppSpacing.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Hello, ${profile['name']}',
                                      style: AppTextStyles.screenTitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    '👋',
                                    style: TextStyle(fontSize: 22),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Keep going! You're on track.",
                                style: AppTextStyles.cardSubtitle,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            // Ikon Search dibiarkan dummy sesuai permintaan
                            IconButton(
                              icon: Icon(
                                Icons.search_rounded,
                                color: AppColors.textPrimary,
                                size: 22,
                              ),
                              onPressed: () {},
                            ),
                            // Ikon Notifikasi mengarah ke tab Notifications + badge unread
                            ListenableBuilder(
                              listenable: AppDataController.instance,
                              builder: (context, _) {
                                final hasUnread = AppDataController
                                    .instance
                                    .notifications
                                    .any((n) => n['isRead'] != true);
                                return IconButton(
                                  icon: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Icon(
                                        Icons.notifications_none_rounded,
                                        color: AppColors.textPrimary,
                                        size: 22,
                                      ),
                                      if (hasUnread)
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: AppColors.error,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  onPressed: () {
                                    // Indeks 2 = NotificationsTab pada MainNavigationScreen
                                    AppDataController.instance.switchMainTab(2);
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // MY BOARDS
                    _buildSectionHeader(
                      'My Boards',
                      onViewAll: () {
                        final visible = _getVisibleBoards(isManager, profile);
                        _showAllBoardsModal(context, visible);
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 116,
                      child: ListenableBuilder(
                        listenable: AppDataController.instance,
                        builder: (context, _) {
                          final visibleBoards = _getVisibleBoards(
                            isManager,
                            profile,
                          );

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
                                boardId: b['id'].toString(),
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

                    // TODAY'S TASKS (REAL-TIME DARI SUPABASE)
                    _buildSectionHeader(
                      "Today's Tasks",
                      onViewAll: () {
                        // Indeks 1 = TasksTab pada MainNavigationScreen
                        AppDataController.instance.switchMainTab(1);
                      },
                    ),
                    const SizedBox(height: 12),
                    ListenableBuilder(
                      listenable: AppDataController.instance,
                      builder: (context, _) {
                        final visibleBoardIds = _getVisibleBoards(
                          isManager,
                          profile,
                        ).map((b) => b['id']?.toString() ?? '').toSet();

                        final todayTasks = AppDataController.instance
                            .getTodayTasks(visibleBoardIds: visibleBoardIds);

                        if (todayTasks.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 14,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: AppRadius.roundedLg,
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Text(
                              'Tidak ada tugas dengan tenggat hari ini.',
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

                    // RECENT ACTIVITY (REAL-TIME & PERMANEN DARI SUPABASE)
                    _buildSectionHeader(
                      'Recent Activity',
                      onViewAll: () {
                        _showAllActivitiesModal(
                          context,
                          AppDataController.instance.recentActivities,
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    ListenableBuilder(
                      listenable: AppDataController.instance,
                      builder: (context, _) {
                        final activities =
                            AppDataController.instance.recentActivities;
                        if (activities.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 14,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: AppRadius.roundedLg,
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Text(
                              'Belum ada aktivitas tercatat.',
                              style: AppTextStyles.cardSubtitle,
                            ),
                          );
                        }
                        // Tampilkan maksimal 5 aktivitas terbaru di beranda
                        final previewActivities = activities.take(5).toList();
                        return Column(
                          children: previewActivities
                              .map(
                                (act) => _buildActivityItem(
                                  context,
                                  activity: act,
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
    final String taskId = task['id']?.toString() ?? '';
    final priority = task['priority']?.toString() ?? 'Low';
    final isDone = task['isDone'] == true;
    final isOverdue = AppDataController.instance.isTaskOverdue(task);
    final board = AppDataController.instance.boards.firstWhere(
      (b) => b['id'] == task['boardId'],
      orElse: () => {'title': 'Board'},
    );

    final String dueDateLabel =
        (task['dueDate']?.toString() ?? task['date']?.toString() ?? 'Hari ini')
            .trim();
    final String dueTimeLabel = (task['dueTime']?.toString() ?? '').trim();
    final String scheduleText =
        (dueTimeLabel.isNotEmpty && dueTimeLabel != 'Waktu')
            ? '$dueDateLabel • $dueTimeLabel'
            : dueDateLabel;

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
            builder: (_) => TaskDetailScreen(taskId: taskId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.roundedLg,
          border: Border.all(
            color: isOverdue
                ? AppColors.error.withOpacity(0.45)
                : AppColors.borderLight,
            width: 1.2,
          ),
          boxShadow: [AppShadows.card],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                if (!AppDataController.instance.canUserEditTask(taskId)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Tugas dikunci karena melewati tenggat waktu.',
                      ),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }
                AppDataController.instance.toggleTaskCompletion(taskId);
              },
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isDone ? AppColors.primary : Colors.transparent,
                  borderRadius: AppRadius.roundedXs,
                  border: Border.all(
                    color: isDone
                        ? AppColors.primary
                        : (isOverdue ? AppColors.error : AppColors.border),
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
                    task['title']?.toString() ?? 'Untitled Task',
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
                    '${board['title']} • $scheduleText',
                    style: AppTextStyles.cardSubtitle.copyWith(
                      fontSize: 11,
                      color: isOverdue
                          ? AppColors.error
                          : AppColors.textSecondary,
                    ),
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

  Widget _buildActivityItem(
    BuildContext context, {
    required Map<String, dynamic> activity,
    bool closeModalFirst = false,
  }) {
    final String title = activity['title']?.toString() ?? '';
    final String time = activity['time']?.toString() ?? '';
    final bool hasLink =
        (activity['targetId']?.toString().isNotEmpty ?? false) ||
        (activity['boardId']?.toString().isNotEmpty ?? false);

    return GestureDetector(
      onTap: hasLink
          ? () => _handleActivityTap(
                context,
                activity,
                closeModalFirst: closeModalFirst,
              )
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.roundedMd,
          border: Border.all(color: AppColors.borderLight.withOpacity(0.6)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primarySurface,
              child: const Icon(
                Icons.history_rounded,
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
            if (hasLink)
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}