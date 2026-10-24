import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../theme/app_theme.dart';
import '../widgets/top_decor_blob.dart';
import 'task_detail_screen.dart';

class TasksTab extends StatefulWidget {
  const TasksTab({super.key});

  @override
  State<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab> {
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          TopDecorBlob(size: 150),
          SafeArea(
            child: Padding(
              padding: AppSpacing.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tasks', style: AppTextStyles.screenTitle),
                  const SizedBox(height: 16),

                  // Pill-shaped Search Bar
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.roundedPill,
                      border: Border.all(
                        color: AppColors.borderLight,
                        width: 1.2,
                      ),
                      boxShadow: const [AppShadows.subtleBorder],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value.toLowerCase();
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Search tasks...',
                              hintStyle: AppTextStyles.cardSubtitle.copyWith(
                                fontSize: 13,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                            style: AppTextStyles.cardTitle.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.tune_rounded,
                          color: AppColors.textSecondary,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Pill Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: ['All', 'To Do', 'In Progress', 'Done'].map((
                        filter,
                      ) {
                        final isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedFilter = filter;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.surface,
                                borderRadius: AppRadius.roundedPill,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.borderLight,
                                  width: 1.2,
                                ),
                              ),
                              child: Text(
                                filter,
                                style: AppTextStyles.filterChipText.copyWith(
                                  color: isSelected
                                      ? AppColors.textLight
                                      : AppColors.textSecondary,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Task Cards List (Reaktif Membaca AppDataController)
                  Expanded(
                    child: ListenableBuilder(
                      listenable: AppDataController.instance,
                      builder: (context, _) {
                        // 1. Ambil data asli
                        List<Map<String, dynamic>> displayTasks = List.from(
                          AppDataController.instance.tasks,
                        );

                        // 2. Filter Kategori (All, To Do, dsb)
                        if (_selectedFilter != 'All') {
                          displayTasks = displayTasks
                              .where((t) => t['status'] == _selectedFilter)
                              .toList();
                        }

                        // 3. Filter Pencarian Teks
                        if (_searchQuery.isNotEmpty) {
                          displayTasks = displayTasks
                              .where(
                                (t) => t['title']
                                    .toString()
                                    .toLowerCase()
                                    .contains(_searchQuery),
                              )
                              .toList();
                        }

                        if (displayTasks.isEmpty) {
                          return Center(
                            child: Text(
                              'Tidak ada tugas yang sesuai.',
                              style: AppTextStyles.cardSubtitle,
                            ),
                          );
                        }

                        return ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: displayTasks.length,
                          itemBuilder: (context, index) {
                            final task = displayTasks[index];
                            return _buildTaskCard(task);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    final bool isCompleted = task['isDone'] as bool;
    final String priority = task['priority'] ?? 'Low';

    // Cari nama board berdasarkan boardId
    final board = AppDataController.instance.boards.firstWhere(
      (b) => b['id'] == task['boardId'],
      orElse: () => {'title': 'Unknown Board'},
    );
    final boardName = board['title'];

    Color badgeBgColor;
    Color badgeTextColor;
    if (priority == 'High') {
      badgeBgColor = AppColors.priorityHighBg;
      badgeTextColor = AppColors.priorityHighText;
    } else if (priority == 'Medium') {
      badgeBgColor = AppColors.priorityMediumBg;
      badgeTextColor = AppColors.priorityMediumText;
    } else {
      badgeBgColor = AppColors.priorityLowBg;
      badgeTextColor = AppColors.priorityLowText;
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
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.roundedLg,
          border: Border.all(color: AppColors.borderLight, width: 1.2),
          boxShadow: const [AppShadows.card],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    AppDataController.instance.toggleTaskCompletion(task['id']);
                  },
                  child: Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: AppRadius.roundedXs,
                      border: Border.all(
                        color: isCompleted
                            ? AppColors.primary
                            : AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task['title'] as String,
                        style: AppTextStyles.cardTitle.copyWith(
                          fontSize: 13,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: isCompleted
                              ? AppColors.textMuted
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        boardName,
                        style: AppTextStyles.cardSubtitle.copyWith(
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    borderRadius: AppRadius.roundedPill,
                  ),
                  child: Text(
                    priority,
                    style: AppTextStyles.badgeText.copyWith(
                      color: badgeTextColor,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 13,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        task['date'] ?? 'No Date',
                        style: AppTextStyles.cardSubtitle.copyWith(
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 11,
                    backgroundColor: AppColors.primarySurface,
                    child: const Icon(
                      Icons.person_rounded,
                      size: 13,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
