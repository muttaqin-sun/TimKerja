import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../theme/app_theme.dart';

class NotificationsTab extends StatefulWidget {
  const NotificationsTab({super.key});

  @override
  State<NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<NotificationsTab> {
  String _selectedTopFilter = 'All';

  // State untuk Bottom Sheet Filter
  List<String> _selectedPriorities = []; // Kosong = semua prioritas
  String _selectedSort = 'Terbaru';

  // GETTER LOGIKA FILTER & SORTING (MEMBACA APPDATACONTROLLER)
  List<Map<String, dynamic>> _getFilteredNotifications() {
    List<Map<String, dynamic>> list = List.from(
      AppDataController.instance.notifications,
    );

    // 1. Filter Kategori Atas (All, Mentions, Assignments, Due Dates)
    if (_selectedTopFilter != 'All') {
      list = list.where((item) => item['type'] == _selectedTopFilter).toList();
    }

    // 2. Filter Bottom Sheet (Prioritas: High, Medium, Low)
    if (_selectedPriorities.isNotEmpty) {
      list = list
          .where((item) => _selectedPriorities.contains(item['priority']))
          .toList();
    }

    // 3. Pengurutan (Sorting)
    if (_selectedSort == 'Prioritas tertinggi') {
      const priorityMap = {'High': 3, 'Medium': 2, 'Low': 1};
      list.sort((a, b) {
        int pA = priorityMap[a['priority']] ?? 0;
        int pB = priorityMap[b['priority']] ?? 0;
        return pB.compareTo(pA); // High ke Low
      });
    } else if (_selectedSort == 'Terbaru') {
      list.sort((a, b) {
        DateTime tA = a['timestamp'] as DateTime;
        DateTime tB = b['timestamp'] as DateTime;
        return tB.compareTo(tA); // Terbaru ke Lama
      });
    }

    return list;
  }

  void _showFilterBottomSheet() {
    List<String> tempPriorities = List.from(_selectedPriorities);
    String tempSort = _selectedSort;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: SingleChildScrollView(
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
                        'Filter Notifikasi',
                        style: AppTextStyles.screenTitle.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 16),

                      Text('Prioritas', style: AppTextStyles.sectionTitle),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildPriorityFilterChip(
                            'High',
                            Icons.error_outline_rounded,
                            AppColors.error,
                            AppColors.priorityHighBg,
                            tempPriorities.contains('High'),
                            (selected) {
                              setModalState(() {
                                selected
                                    ? tempPriorities.add('High')
                                    : tempPriorities.remove('High');
                              });
                            },
                          ),
                          const SizedBox(width: 6),
                          _buildPriorityFilterChip(
                            'Medium',
                            Icons.access_time_rounded,
                            AppColors.warning,
                            AppColors.priorityMediumBg,
                            tempPriorities.contains('Medium'),
                            (selected) {
                              setModalState(() {
                                selected
                                    ? tempPriorities.add('Medium')
                                    : tempPriorities.remove('Medium');
                              });
                            },
                          ),
                          const SizedBox(width: 6),
                          _buildPriorityFilterChip(
                            'Low',
                            Icons.info_outline_rounded,
                            AppColors.success,
                            AppColors.priorityLowBg,
                            tempPriorities.contains('Low'),
                            (selected) {
                              setModalState(() {
                                selected
                                    ? tempPriorities.add('Low')
                                    : tempPriorities.remove('Low');
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Text(
                        'Urutkan berdasarkan',
                        style: AppTextStyles.sectionTitle,
                      ),
                      const SizedBox(height: 4),
                      RadioListTile<String>(
                        title: Text(
                          'Prioritas tertinggi',
                          style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
                        ),
                        subtitle: Text(
                          'High → Medium → Low',
                          style: AppTextStyles.cardSubtitle,
                        ),
                        value: 'Prioritas tertinggi',
                        groupValue: tempSort,
                        activeColor: AppColors.primary,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        onChanged: (value) =>
                            setModalState(() => tempSort = value!),
                      ),
                      RadioListTile<String>(
                        title: Text(
                          'Terbaru',
                          style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
                        ),
                        subtitle: Text(
                          'Notifikasi terbaru di paling atas',
                          style: AppTextStyles.cardSubtitle,
                        ),
                        value: 'Terbaru',
                        groupValue: tempSort,
                        activeColor: AppColors.primary,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        onChanged: (value) =>
                            setModalState(() => tempSort = value!),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setModalState(() {
                                  tempPriorities.clear();
                                  tempSort = 'Terbaru';
                                });
                              },
                              child: const Text('Reset'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedPriorities = tempPriorities;
                                  _selectedSort = tempSort;
                                });
                                Navigator.pop(context);
                              },
                              child: const Text('Apply'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPriorityFilterChip(
    String label,
    IconData icon,
    Color iconColor,
    Color bgColor,
    bool isSelected,
    Function(bool) onSelected,
  ) {
    return FilterChip(
      showCheckmark: false,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: AppColors.surface,
      selectedColor: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? iconColor : AppColors.border),
      ),
      labelStyle: TextStyle(
        color: isSelected ? iconColor : AppColors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notifications',
                    style: AppTextStyles.authTitle.copyWith(fontSize: 24),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          AppDataController.instance
                              .markAllNotificationsAsRead();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'All notifications are marked as read',
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.done_all_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        label: Text(
                          'read All',
                          style: AppTextStyles.cardSubtitle.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: Icon(
                          Icons.tune_rounded,
                          color: AppColors.textPrimary,
                        ),
                        onPressed: _showFilterBottomSheet,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Top Filter Chips (All, Mentions, Assignments, Due Dates)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: ['All', 'Mentions', 'Assignments', 'Due Dates'].map(
                    (filter) {
                      final isSelected = _selectedTopFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.surfaceMuted,
                          showCheckmark: false,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          onSelected: (selected) {
                            setState(() {
                              _selectedTopFilter = filter;
                            });
                          },
                        ),
                      );
                    },
                  ).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Indikator Filter Aktif
              if (_selectedPriorities.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Text('Filtered by: ', style: AppTextStyles.cardSubtitle),
                      ..._selectedPriorities.map(
                        (p) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            p,
                            style: AppTextStyles.cardTitle.copyWith(
                              fontSize: 12,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Notifications List (Reaktif Membaca Data Controller & Filter)
              Expanded(
                child: ListenableBuilder(
                  listenable: AppDataController.instance,
                  builder: (context, _) {
                    final displayList = _getFilteredNotifications();

                    if (displayList.isEmpty) {
                      return Center(
                        child: Text(
                          'There are no notifications according to the filter',
                          style: AppTextStyles.cardSubtitle,
                        ),
                      );
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: displayList.length,
                      itemBuilder: (context, index) {
                        final item = displayList[index];
                        return _buildNotificationItem(
                          id: item['id'],
                          icon: item['icon'],
                          title: item['title'],
                          subtitle: item['subtitle'],
                          time: item['time'],
                          priority: item['priority'],
                          isRead: item['isRead'] ?? false,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required String id,
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required String priority,
    required bool isRead,
  }) {
    Color badgeBgColor;
    Color badgeTextColor;
    Color dynamicIconColor;

    switch (priority) {
      case 'High':
        badgeBgColor = AppColors.priorityHighBg;
        badgeTextColor = AppColors.priorityHighText;
        dynamicIconColor = AppColors.error;
        break;
      case 'Medium':
        badgeBgColor = AppColors.priorityMediumBg;
        badgeTextColor = AppColors.priorityMediumText;
        dynamicIconColor = AppColors.warning;
        break;
      case 'Low':
      default:
        badgeBgColor = AppColors.priorityLowBg;
        badgeTextColor = AppColors.priorityLowText;
        dynamicIconColor = AppColors.success;
        break;
    }

    return Dismissible(
      key: Key(id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Delete Notifications?',
              style: AppTextStyles.cardTitle.copyWith(fontSize: 18),
            ),
            content: Text(
              'Are you sure you want to delete this notification?',
              style: AppTextStyles.cardSubtitle,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text(
                  'Cancelled',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        AppDataController.instance.deleteNotification(id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification has been deleted'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.delete_sweep_rounded,
              color: Colors.white,
              size: 26,
            ),
            const SizedBox(width: 8),
            Text(
              'Delete',
              style: AppTextStyles.cardTitle.copyWith(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead ? AppColors.surface : AppColors.surface.withAlpha(245),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRead
                ? AppColors.borderLight
                : AppColors.primary.withOpacity(0.35),
            width: isRead ? 1.0 : 1.4,
          ),
          boxShadow: const [AppShadows.subtleBorder],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: dynamicIconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: dynamicIconColor),
                ),
                if (!isRead)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTextStyles.cardTitle.copyWith(
                            fontSize: 14,
                            fontWeight: isRead
                                ? FontWeight.w600
                                : FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: badgeBgColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              priority,
                              style: AppTextStyles.badgeText.copyWith(
                                color: badgeTextColor,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Mark as read action di bawah level prioritas High-Low
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              if (!isRead) {
                                AppDataController.instance
                                    .markNotificationAsRead(id);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isRead
                                        ? Icons.done_all_rounded
                                        : Icons.check_circle_outline_rounded,
                                    size: 13,
                                    color: isRead
                                        ? AppColors.textMuted
                                        : AppColors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isRead ? 'Dibaca' : 'Tandai dibaca',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: isRead
                                          ? FontWeight.normal
                                          : FontWeight.w600,
                                      color: isRead
                                          ? AppColors.textMuted
                                          : AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: AppTextStyles.cardSubtitle.copyWith(height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    time,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
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
