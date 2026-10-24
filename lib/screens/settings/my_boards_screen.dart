import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../data/app_data.dart';

class MyBoardsScreen extends StatefulWidget {
  const MyBoardsScreen({super.key});

  @override
  State<MyBoardsScreen> createState() => _MyBoardsScreenState();
}

class _MyBoardsScreenState extends State<MyBoardsScreen> {
  String _selectedFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Boards',
          style: AppTextStyles.cardTitle.copyWith(fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit_square,
              size: 20,
              color: AppColors.textPrimary,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: AppDataController.instance,
        builder: (context, _) {
          List<Map<String, dynamic>> displayBoards = List.from(
            AppDataController.instance.boards,
          );

          if (_selectedFilter == 'Dibuat oleh Saya') {
            displayBoards = displayBoards
                .where((b) => b['privacy'] != 'Public')
                .toList();
          } else if (_selectedFilter == 'Diikuti') {
            displayBoards = displayBoards
                .where(
                  (b) =>
                      b['privacy'] == 'Public' || b['privacy'] == 'Workspace',
                )
                .toList();
          }

          return ListView(
            padding: AppSpacing.screenPadding,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.roundedLg,
                  border: Border.all(color: AppColors.borderLight, width: 1.2),
                  boxShadow: const [AppShadows.card],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.business_center_rounded,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Board',
                                style: AppTextStyles.cardSubtitle,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${AppDataController.instance.boards.length}',
                                style: AppTextStyles.statNumber,
                              ),
                            ],
                          ),
                          Container(
                            height: 40,
                            width: 1,
                            color: AppColors.borderLight,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Board Aktif',
                                style: AppTextStyles.cardSubtitle,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${displayBoards.length}',
                                style: AppTextStyles.statNumber,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildFilterChip('Semua'),
                    _buildFilterChip('Dibuat oleh Saya'),
                    _buildFilterChip('Diikuti'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              if (displayBoards.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      'Tidak ada board yang sesuai.',
                      style: AppTextStyles.cardSubtitle,
                    ),
                  ),
                )
              else
                ...displayBoards.map((board) {
                  Color baseColor = AppColors.primary;
                  if (board['color'] != null) {
                    baseColor = board['color'] is Color
                        ? board['color']
                        : Color(board['color']);
                  }

                  // Mengambil array members secara dinamis
                  final members = (board['members'] as List?) ?? [];

                  return _buildBoardListItem(
                    title: board['title'] ?? 'Untitled',
                    subtitle: board['privacy'] == 'Private'
                        ? 'Dibuat oleh Anda'
                        : 'Ruang Kolaborasi',
                    iconBg: baseColor.withOpacity(0.15),
                    iconColor: baseColor,
                    members: members,
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final bool isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: AppRadius.roundedPill,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildBoardListItem({
    required String title,
    required String subtitle,
    required Color iconBg,
    required Color iconColor,
    required List<dynamic> members,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.roundedLg,
        border: Border.all(color: AppColors.borderLight, width: 1.2),
        boxShadow: const [AppShadows.subtleBorder],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: AppRadius.roundedSm,
            ),
            child: Icon(Icons.landscape_rounded, color: iconColor, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
                    ),
                    Icon(
                      Icons.more_horiz_rounded,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 8),
                _buildAvatarStack(members),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textMuted,
            size: 24,
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    List<String> parts = name.split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  // LOGIKA BARU: Tumpukan avatar otomatis membaca list members
  Widget _buildAvatarStack(List<dynamic> members) {
    if (members.isEmpty)
      return Text(
        'Belum ada anggota',
        style: AppTextStyles.cardSubtitle.copyWith(fontSize: 11),
      );

    const int maxDisplay = 3;
    final int total = members.length;
    final int displayCount = total > maxDisplay ? maxDisplay : total;

    // Hitung lebar dinamis berdasarkan jumlah avatar yang dirender
    final double stackWidth =
        (displayCount * 18.0) + (total > maxDisplay ? 24.0 : 8.0);

    return SizedBox(
      width: stackWidth,
      height: 24,
      child: Stack(
        children: [
          for (int i = 0; i < displayCount; i++)
            Positioned(
              left: i * 16.0,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(members[i]['color']).withOpacity(0.85),
                  border: Border.all(color: AppColors.surface, width: 2),
                ),
                child: Center(
                  child: Text(
                    _getInitials(members[i]['name']),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          if (total > maxDisplay)
            Positioned(
              left: displayCount * 16.0,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceMuted,
                  border: Border.all(color: AppColors.surface, width: 2),
                ),
                child: Center(
                  child: Text(
                    '+${total - maxDisplay}',
                    style: AppTextStyles.cardSubtitle.copyWith(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
