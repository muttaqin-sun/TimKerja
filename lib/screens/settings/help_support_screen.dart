import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  void _navigateToPlaceholder(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UnderDevelopmentScreen(title: title)),
    );
  }

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
          'Help & Support',
          style: AppTextStyles.cardTitle.copyWith(fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Illustration
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Icon(
                    Icons.support_agent_rounded,
                    size: 80,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Ada yang bisa kami bantu?',
              style: AppTextStyles.screenTitle.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 12),
            Text(
              'Temukan jawaban dari pertanyaan umum atau hubungi tim dukungan kami jika membutuhkan bantuan lebih lanjut.',
              textAlign: TextAlign.center,
              style: AppTextStyles.cardSubtitle.copyWith(height: 1.5),
            ),
            const SizedBox(height: 40),

            _buildMenuItem(
              context,
              icon: Icons.menu_book_rounded,
              title: 'FAQ',
              subtitle: 'Pertanyaan yang sering diajukan',
              onTap: () => _navigateToPlaceholder(context, 'FAQ'),
            ),
            _buildMenuItem(
              context,
              icon: Icons.chat_rounded,
              title: 'Hubungi Kami',
              subtitle: 'Kirim laporan atau pertanyaan',
              onTap: () => _navigateToPlaceholder(context, 'Hubungi Kami'),
            ),
            _buildMenuItem(
              context,
              icon: Icons.bug_report_rounded,
              title: 'Laporkan Masalah',
              subtitle: 'Beri tahu kami jika ada bug',
              onTap: () => _navigateToPlaceholder(context, 'Laporkan Masalah'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.roundedLg,
          border: Border.all(color: AppColors.borderLight, width: 1.2),
          boxShadow: const [AppShadows.subtleBorder],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.cardSubtitle),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

// Layar Placeholder (Dalam Pengembangan)
class UnderDevelopmentScreen extends StatelessWidget {
  final String title;
  const UnderDevelopmentScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: AppTextStyles.cardTitle.copyWith(fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction_rounded,
              size: 80,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              'Dalam Proses Pengembangan',
              style: AppTextStyles.screenTitle.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              'Halaman $title akan segera hadir.',
              style: AppTextStyles.cardSubtitle,
            ),
          ],
        ),
      ),
    );
  }
}
