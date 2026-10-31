import 'package:flutter/material.dart';

import '../../../../data/app_data.dart';
import '../../../../theme/app_theme.dart';
import '../../board_screen.dart'; // Digunakan untuk navigasi jika dibutuhkan

class GeneralTab extends StatefulWidget {
  final String boardId;
  final bool isManager;

  const GeneralTab({super.key, required this.boardId, required this.isManager});

  @override
  State<GeneralTab> createState() => _GeneralTabState();
}

class _GeneralTabState extends State<GeneralTab> {
  // Fungsi memunculkan Dialog Visibilitas dengan latar belakang agak gelap
  void _showVisibilityDialog(String currentPrivacy) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(
        0.55,
      ), // Latar belakang lebih gelap
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Visibilitas Board',
                  style: AppTextStyles.screenTitle.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 16),
                _buildPrivacyOption(
                  title: 'Private',
                  description: 'Hanya anggota yang diundang secara khusus yang dapat melihat dan mengedit board ini.',
                  icon: Icons.lock_outline_rounded,
                  value: 'Private',
                  currentValue: currentPrivacy,
                ),
                const Divider(height: 1),
                _buildPrivacyOption(
                  title: 'Workspace',
                  description: 'Semua anggota tim yang berada di workspace ini dapat menemukan dan bergabung ke board.',
                  icon: Icons.business_rounded,
                  value: 'Workspace',
                  currentValue: currentPrivacy,
                ),
                const Divider(height: 1),
                _buildPrivacyOption(
                  title: 'Public',
                  description: 'Siapa saja di internet yang memiliki tautan dapat melihat board ini (Read-only).',
                  icon: Icons.public_rounded,
                  value: 'Public',
                  currentValue: currentPrivacy,
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Tutup',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrivacyOption({
    required String title,
    required String description,
    required IconData icon,
    required String value,
    required String currentValue,
  }) {
    final isSelected = currentValue == value;
    return InkWell(
      onTap: () {
        if (!widget.isManager) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Hanya Pembuat Board yang dapat mengubah privasi.'),
            ),
          );
          return;
        }
        // Update privasi board melalui state controller global
        AppDataController.instance.updateBoardDetails(
          widget.boardId,
          privacy: value,
        );
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.cardTitle.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.cardSubtitle.copyWith(
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDummyToast(String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pengaturan $featureName belum tersedia (Dummy).'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppDataController.instance,
      builder: (context, _) {
        final board = AppDataController.instance.boards.firstWhere(
          (b) => b['id'] == widget.boardId,
          orElse: () => {
            'title': 'Board Tidak Ditemukan',
            'desc': '',
            'privacy': 'Private',
          },
        );

        final String title = board['title'] ?? 'Untitled Board';
        final String desc = board['desc']?.toString().isNotEmpty == true
            ? board['desc']
            : 'Board untuk mengelola tugas dan kegiatan.';
        final String privacy = board['privacy'] ?? 'Private';

        return ListView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          children: [
            // 1. INFORMASI BOARD
            _buildSectionHeader('Informasi Board'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.roundedLg,
                border: Border.all(color: AppColors.borderLight, width: 1.2),
                boxShadow: const [AppShadows.card],
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: AppRadius.roundedMd,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.school_rounded, // Ikon representasi gambar wisuda
                        color: AppColors.primary,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                title,
                                style: AppTextStyles.cardTitle.copyWith(
                                  fontSize: 15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primarySurface,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Akademik',
                                style: AppTextStyles.cardSubtitle.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          desc,
                          style: AppTextStyles.cardSubtitle.copyWith(
                            fontSize: 11,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. PENGATURAN AKSES
            _buildSectionHeader(
              'Pengaturan Akses',
              trailingIcon: Icons.lock_rounded,
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.roundedLg,
                border: Border.all(color: AppColors.borderLight, width: 1.2),
                boxShadow: const [AppShadows.card],
              ),
              child: Column(
                children: [
                  // Visibilitas (Aktif)
                  _buildAccessItem(
                    icon: Icons.visibility_outlined,
                    title: 'Visibilitas Board',
                    subtitle: privacy == 'Private'
                        ? 'Hanya anggota yang diundang'
                        : privacy == 'Workspace'
                        ? 'Seluruh anggota organisasi'
                        : 'Publik (Siapa saja memiliki tautan)',
                    onTap: () => _showVisibilityDialog(privacy),
                  ),
                  Divider(height: 1, color: AppColors.borderLight),
                  // Dummy 1
                  _buildAccessItem(
                    icon: Icons.add_circle_outline_rounded,
                    title: 'Izin Membuat Card',
                    subtitle: 'Semua anggota',
                    onTap: () => _showDummyToast('Izin Membuat Card'),
                  ),
                  Divider(height: 1, color: AppColors.borderLight),
                  // Dummy 2
                  _buildAccessItem(
                    icon: Icons.edit_outlined,
                    title: 'Izin Mengedit Card',
                    subtitle: 'Semua anggota',
                    onTap: () => _showDummyToast('Izin Mengedit Card'),
                  ),
                  Divider(height: 1, color: AppColors.borderLight),
                  // Dummy 3
                  _buildAccessItem(
                    icon: Icons.delete_outline_rounded,
                    title: 'Izin Menghapus Card',
                    subtitle: 'Hanya admin & pengelola',
                    onTap: () => _showDummyToast('Izin Menghapus Card'),
                  ),
                  Divider(height: 1, color: AppColors.borderLight),
                  // Dummy 4
                  _buildAccessItem(
                    icon: Icons.person_add_alt_1_outlined,
                    title: 'Izin Mengundang Anggota',
                    subtitle: 'Hanya admin & pengelola',
                    onTap: () => _showDummyToast('Izin Mengundang Anggota'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 3. PENGELOLAAN BOARD
            _buildSectionHeader('Pengelolaan Board'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildManagementButton(
                    icon: Icons.archive_outlined,
                    label: 'Arsipkan\nBoard',
                    color: AppColors.primary,
                    bgColor: AppColors.primarySurface,
                    onTap: () => _showDummyToast('Arsipkan Board'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildManagementButton(
                    icon: Icons.content_copy_rounded,
                    label: 'Duplikat\nBoard',
                    color: AppColors.primary,
                    bgColor: AppColors.primarySurface,
                    onTap: () => _showDummyToast('Duplikat Board'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildManagementButton(
                    icon: Icons.delete_outline_rounded,
                    label: 'Hapus\nBoard',
                    color: AppColors.error,
                    bgColor: AppColors.priorityHighBg, // Latar merah pudar
                    onTap: widget.isManager
                        ? () => _showDeleteBoardDialog(context, board)
                        : () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Hanya Pembuat Board yang dapat menghapus.',
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            // Footer Info Aktivitas
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 12,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  'Dibuat pada 12 Okt 2025',
                  style: AppTextStyles.cardSubtitle.copyWith(fontSize: 10),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.access_time_rounded,
                  size: 12,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  'Aktivitas terakhir: 2 jam lalu',
                  style: AppTextStyles.cardSubtitle.copyWith(fontSize: 10),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  // Widget Pembantu: Judul Seksi (Dengan garis aksen kiri & opsional ikon kanan)
  Widget _buildSectionHeader(String title, {IconData? trailingIcon}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTextStyles.sectionTitle.copyWith(fontSize: 15),
            ),
          ],
        ),
        if (trailingIcon != null)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(trailingIcon, color: Colors.white, size: 12),
          ),
      ],
    );
  }

  // Widget Pembantu: Item Akses (Baris menu di dalam pengaturan akses)
  Widget _buildAccessItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.cardTitle.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.cardSubtitle.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // Widget Pembantu: Tombol kotak untuk bagian Pengelolaan
  Widget _buildManagementButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.roundedLg,
          border: Border.all(color: AppColors.borderLight, width: 1.2),
          boxShadow: const [AppShadows.card],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: AppRadius.roundedMd,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.cardTitle.copyWith(
                fontSize: 11,
                color: color,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog asli fungsi penghapusan board permanen
  void _showDeleteBoardDialog(
    BuildContext context,
    Map<String, dynamic> board,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
        title: Text(
          'Hapus Board?',
          style: AppTextStyles.screenTitle.copyWith(
            fontSize: 18,
            color: AppColors.error,
          ),
        ),
        content: Text(
          'Seluruh list dan task di dalam board "${board['title']}" akan dihapus permanen.',
          style: AppTextStyles.cardSubtitle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              AppDataController.instance.deleteBoard(widget.boardId);
              Navigator.pop(ctx); // Tutup dialog
              Navigator.pop(context); // Keluar dari layar setting
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus Permanen'),
          ),
        ],
      ),
    );
  }
}
