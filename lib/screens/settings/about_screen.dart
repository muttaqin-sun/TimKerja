import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
          'About',
          style: AppTextStyles.cardTitle.copyWith(fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Header Logo
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.info, // Warna biru seperti di desain
                borderRadius: AppRadius.roundedLg,
              ),
              child: const Icon(
                Icons.groups_rounded,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'TimKerja',
              style: AppTextStyles.screenTitle.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 4),
            Text(
              'Kerja bareng, hasil maksimal.',
              style: AppTextStyles.cardSubtitle,
            ),
            const SizedBox(height: 32),

            // Versi Info List
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.roundedLg,
                border: Border.all(color: AppColors.borderLight, width: 1.2),
              ),
              child: Column(
                children: [
                  _buildListRow(
                    Icons.check_circle_outline_rounded,
                    'Versi Aplikasi',
                    'v1.0.0',
                  ),
                  Divider(height: 1, color: AppColors.borderLight),
                  _buildListRow(
                    Icons.groups_outlined,
                    'Pengembang',
                    'Tim Pengembangan',
                  ),
                  Divider(height: 1, color: AppColors.borderLight),
                  _buildListRow(
                    Icons.calendar_today_outlined,
                    'Tahun Rilis',
                    '2026',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tentang TimKerja Info Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.roundedLg,
                border: Border.all(color: AppColors.borderLight, width: 1.2),
                boxShadow: const [AppShadows.subtleBorder],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text('Tentang TimKerja', style: AppTextStyles.cardTitle),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'TimKerja adalah aplikasi manajemen tugas dan kolaborasi tim yang dirancang untuk membantu Anda dan tim dalam mengatur pekerjaan, berbagi tugas, dan mencapai tujuan bersama dengan lebih mudah dan efisien.',
                    style: AppTextStyles.cardSubtitle.copyWith(
                      height: 1.5,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Developed by (Dipertahankan dan dipindah ke bawah)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.roundedLg,
                border: Border.all(color: AppColors.borderLight, width: 1.2),
              ),
              child: Column(
                children: [
                  Text(
                    'Developed by:',
                    style: AppTextStyles.cardSubtitle.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Ilham Muttaqin',
                    style: AppTextStyles.cardTitle.copyWith(fontSize: 17),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sistem Informasi - UNUGIRI',
                    style: AppTextStyles.linkText.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Final Project Demo for\nManajemen Proyek SI & Pemrograman Aplikasi Bergerak',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.cardSubtitle.copyWith(
                      fontSize: 12,
                      height: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildListRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(
            title,
            style: AppTextStyles.cardTitle.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.cardSubtitle.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
