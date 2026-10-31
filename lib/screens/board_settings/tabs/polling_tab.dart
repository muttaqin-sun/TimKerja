import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../create_poll_screen.dart';

class PollingTab extends StatelessWidget {
  final String boardId;
  final bool isManager;

  const PollingTab({super.key, required this.boardId, required this.isManager});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daftar Polling',
              style: AppTextStyles.screenTitle.copyWith(fontSize: 18),
            ),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreatePollScreen(
                      boardId: boardId,
                      boardTitle: 'Kuliah - TI',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add, size: 16),
              label: const Text(
                'Buat Polling',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                backgroundColor: Colors.white,
                side: const BorderSide(color: AppColors.primary, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                minimumSize: Size.zero,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildPollCard(),
      ],
    );
  }

  Widget _buildPollCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight, width: 1.2),
        boxShadow: const [AppShadows.card],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE6F7F5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.bar_chart_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jadwal Makrab',
                        style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Dibuat oleh Ilham Muttaqin',
                        style: AppTextStyles.cardSubtitle.copyWith(
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '12 Okt 2025',
                            style: AppTextStyles.cardSubtitle.copyWith(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FAF8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Aktif',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey,
                  size: 20,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.people_outline_rounded,
                  size: 16,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 8),
                Text(
                  '6 responden',
                  style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
