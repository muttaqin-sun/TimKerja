import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../data/app_data.dart';

class CreateBoardScreen extends StatefulWidget {
  const CreateBoardScreen({super.key});

  @override
  State<CreateBoardScreen> createState() => _CreateBoardScreenState();
}

class _CreateBoardScreenState extends State<CreateBoardScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  // State untuk Warna Aksen (0 = dummy image upload, 1 dst = warna)
  int _selectedColorIndex = 1;

  // State untuk Privasi
  String _selectedPrivacy = 'Private';

  // Daftar warna aksen dinamis (Dievaluasi di dalam build atau lewat getter)
  List<Color> get _accentColors => [
    Colors.transparent, // Index 0 untuk tombol upload image
    AppColors.primary,
    const Color(0xFF0284C7), // Blue
    const Color(0xFF16A34A), // Green
    const Color(0xFF9333EA), // Purple
    const Color(0xFFF59E0B), // Orange
    const Color(0xFFEF4444), // Red
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // Method untuk memunculkan Modal Dialog Privasi
  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColors.surface, // Dinamis Light/Dark
          shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pilih Tingkat Akses',
                  style: AppTextStyles.screenTitle.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 16),
                _buildPrivacyOption(
                  title: 'Private',
                  description: 'Hanya anggota yang diundang secara khusus yang dapat melihat dan mengedit board ini.',
                  icon: Icons.lock_outline_rounded,
                  value: 'Private',
                ),
                const Divider(height: 1), // Divider otomatis ngikut AppTheme
                _buildPrivacyOption(
                  title: 'Workspace',
                  description: 'Semua anggota tim yang berada di workspace ini dapat menemukan dan bergabung ke board.',
                  icon: Icons.business_rounded,
                  value: 'Workspace',
                ),
                const Divider(height: 1),
                _buildPrivacyOption(
                  title: 'Public',
                  description: 'Siapa saja di internet yang memiliki tautan dapat melihat board ini (Read-only).',
                  icon: Icons.public_rounded,
                  value: 'Public',
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
  }) {
    final isSelected = _selectedPrivacy == value;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPrivacy = value;
        });
        Navigator.pop(context); // Tutup dialog setelah memilih
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Buat Board Baru',
          style: AppTextStyles.screenTitle.copyWith(fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Nama Board
            Text('Nama Board', style: AppTextStyles.inputLabel),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: AppTextStyles.inputText,
              decoration: const InputDecoration(
                hintText: 'Misal: Project Backend, Kuliah SI',
              ),
            ),
            const SizedBox(height: 24),

            // 2. Deskripsi
            Text('Deskripsi Singkat', style: AppTextStyles.inputLabel),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              maxLines: 3,
              style: AppTextStyles.inputText,
              decoration: const InputDecoration(
                hintText: 'Tulis tujuan atau catatan singkat board ini...',
              ),
            ),
            const SizedBox(height: 24),

            // 3. Warna Aksen & Cover Image
            Text('Warna Aksen / Cover', style: AppTextStyles.inputLabel),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: List.generate(_accentColors.length, (index) {
                  final isSelected = _selectedColorIndex == index;
                  final isImageUpload = index == 0;

                  return GestureDetector(
                    onTap: () {
                      if (isImageUpload) {
                        // TODO: Implementasi logika ImagePicker (Dummy untuk saat ini)
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Fitur Upload Gambar (Dummy)'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      }
                      setState(() {
                        _selectedColorIndex = index;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isImageUpload
                            ? AppColors.surfaceMuted
                            : _accentColors[index],
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.borderLight,
                          width: isSelected ? 2.5 : 1,
                        ),
                      ),
                      child: isImageUpload
                          ? Icon(
                              Icons.add_photo_alternate_rounded,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                              size: 20,
                            )
                          : (isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  )
                                : null),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 24),

            // 4. Tingkat Privasi (Menampilkan Modal Dialog saat di-tap)
            Text('Tingkat Privasi / Akses', style: AppTextStyles.inputLabel),
            const SizedBox(height: 8),
            InkWell(
              onTap: _showPrivacyDialog,
              borderRadius: AppRadius.roundedMd,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.roundedMd,
                  border: Border.all(color: AppColors.borderLight, width: 1.2),
                ),
                child: Row(
                  children: [
                    Icon(
                      _selectedPrivacy == 'Private'
                          ? Icons.lock_outline_rounded
                          : _selectedPrivacy == 'Workspace'
                          ? Icons.business_rounded
                          : Icons.public_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedPrivacy,
                            style: AppTextStyles.cardTitle.copyWith(
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Ketuk untuk mengubah hak akses',
                            style: AppTextStyles.cardSubtitle.copyWith(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // 5. Tombol Submit (Disesuaikan Warnanya)
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty) {
                  // Simpan ke memori!
                  AppDataController.instance.addBoard(
                    _nameController.text,
                    _descController.text,
                    _selectedColorIndex == 0
                        ? AppColors.primary
                        : _accentColors[_selectedColorIndex],
                    _selectedPrivacy,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Buat Board'),
            ),
          ],
        ),
      ),
    );
  }
}
