import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  String _selectedSize = 'Normal';

  @override
  Widget build(BuildContext context) {
    final isDarkMode = AppThemeController.instance.isDarkMode;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Appearance',
          style: AppTextStyles.cardTitle.copyWith(fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          Text('Tema Aplikasi', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 6),
          Text(
            'Pilih tampilan yang paling nyaman untuk Anda.',
            style: AppTextStyles.cardSubtitle,
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildThemeCard(
                  title: 'Terang',
                  subtitle: 'Tampilan cerah dengan warna utama biru kehijauan.',
                  icon: Icons.wb_sunny_rounded,
                  isDarkCard: false,
                  isSelected: !isDarkMode,
                  onTap: () {
                    AppThemeController.instance.setThemeMode(ThemeMode.light);
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildThemeCard(
                  title: 'Gelap',
                  subtitle:
                      'Tampilan gelap untuk kenyamanan mata di malam hari.',
                  icon: Icons.nightlight_round,
                  isDarkCard: true,
                  isSelected: isDarkMode,
                  onTap: () {
                    AppThemeController.instance.setThemeMode(ThemeMode.dark);
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          Text('Ukuran Teks', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 6),
          Text(
            'Sesuaikan ukuran teks sesuai kebutuhan Anda.',
            style: AppTextStyles.cardSubtitle,
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(child: _buildTextSizeCard('Kecil', 12)),
              const SizedBox(width: 12),
              Expanded(child: _buildTextSizeCard('Normal', 16)),
              const SizedBox(width: 12),
              Expanded(child: _buildTextSizeCard('Besar', 22)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isDarkCard,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkCard ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: AppRadius.roundedLg,
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDarkCard ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: isSelected ? 2 : 1.2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isDarkCard ? Colors.white : AppColors.primary,
              size: 32,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.cardTitle.copyWith(
                color: isDarkCard ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.cardSubtitle.copyWith(
                color: isDarkCard
                    ? Colors.grey.shade400
                    : const Color(0xFF64748B),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextSizeCard(String title, double iconSize) {
    bool isSelected = _selectedSize == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedSize = title),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.roundedLg,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: isSelected ? 2 : 1.2,
          ),
        ),
        child: Column(
          children: [
            Text(
              'Aa',
              style: TextStyle(
                fontSize: iconSize,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(title, style: AppTextStyles.cardTitle.copyWith(fontSize: 13)),
            const SizedBox(height: 12),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
