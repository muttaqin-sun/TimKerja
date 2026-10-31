import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';

class FilesTab extends StatefulWidget {
  final String boardId;
  final bool isManager;

  const FilesTab({super.key, required this.boardId, required this.isManager});

  @override
  State<FilesTab> createState() => _FilesTabState();
}

class _FilesTabState extends State<FilesTab> {
  // Data statis (dummy) sesuai gambar desain UI
  final _folders = [
    {
      'name': 'Dokumen Administrasi',
      'files': 5,
      'size': '2,3 MB',
      'date': '12 Okt 2025',
    },
    {
      'name': 'Materi dan Referensi',
      'files': 8,
      'size': '4,7 MB',
      'date': '10 Okt 2025',
    },
    {'name': 'Dokumentasi', 'files': 6, 'size': '3,1 MB', 'date': '8 Okt 2025'},
    {'name': 'Lainnya', 'files': 3, 'size': '1,4 MB', 'date': '5 Okt 2025'},
  ];

  final _recentFiles = [
    {
      'name': 'Proposal Kegiatan.pdf',
      'uploader': 'Ilham Muttaqin',
      'size': '2,4 MB',
      'date': '12 Okt 2025',
      'ext': 'pdf',
    },
    {
      'name': 'Notulensi Rapat.docx',
      'uploader': 'Sari',
      'size': '1,1 MB',
      'date': '10 Okt 2025',
      'ext': 'doc',
    },
    {
      'name': 'RAB Kegiatan.xlsx',
      'uploader': 'Budi',
      'size': '860 KB',
      'date': '8 Okt 2025',
      'ext': 'xls',
    },
    {
      'name': 'Desain Poster.jpg',
      'uploader': 'Sari',
      'size': '2,8 MB',
      'date': '6 Okt 2025',
      'ext': 'img',
    },
    {
      'name': 'Materi Pemrograman.pdf',
      'uploader': 'Ilham Muttaqin',
      'size': '1,9 MB',
      'date': '4 Okt 2025',
      'ext': 'pdf',
    },
  ];

  void _showDummyActionToast(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fitur $action belum tersedia (Dummy).'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        // 1. KARTU PENYIMPANAN BOARD
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
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_upload_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Penyimpanan Board',
                      style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStorageStat(
                          Icons.insert_drive_file_outlined,
                          '24',
                          'Total File',
                        ),
                        _buildStorageStat(
                          Icons.folder_outlined,
                          '6',
                          'Total Folder',
                        ),
                        _buildStorageStat(
                          Icons.storage_rounded,
                          '12,5 MB',
                          'Total Ukuran',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. BARIS PENCARIAN & AKSI
        SizedBox(
          height: 40,
          child: Row(
            children: [
              // Search Bar
              Expanded(
                flex: 5,
                child: TextField(
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Cari file/folder',
                    hintStyle: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: AppColors.textMuted,
                      size: 18,
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.borderLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.borderLight),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Tombol Buat Folder
              Expanded(
                flex: 3,
                child: OutlinedButton.icon(
                  onPressed: () => _showDummyActionToast('Buat Folder'),
                  icon: const Icon(Icons.create_new_folder_outlined, size: 14),
                  label: const Text(
                    'Buat Folder',
                    style: TextStyle(fontSize: 11),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.zero,
                    side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Tombol Upload File
              Expanded(
                flex: 3,
                child: OutlinedButton.icon(
                  onPressed: () => _showDummyActionToast('Upload File'),
                  icon: const Icon(Icons.upload_file_rounded, size: 14),
                  label: const Text(
                    'Upload File',
                    style: TextStyle(fontSize: 11),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    backgroundColor: AppColors.primarySurface,
                    padding: EdgeInsets.zero,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 3. DAFTAR FOLDER
        _buildSectionHeader(
          'Folder',
          onSeeAll: () => _showDummyActionToast('Lihat Semua Folder'),
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
            children: List.generate(_folders.length, (index) {
              final folder = _folders[index];
              return Column(
                children: [
                  _buildFolderItem(
                    name: folder['name'].toString(),
                    files: folder['files'] as int,
                    size: folder['size'].toString(),
                    date: folder['date'].toString(),
                    onTap: () =>
                        _showDummyActionToast('Buka ${folder['name']}'),
                  ),
                  if (index < _folders.length - 1)
                    Divider(
                      height: 1,
                      color: AppColors.borderLight,
                      indent: 16,
                      endIndent: 16,
                    ),
                ],
              );
            }),
          ),
        ),
        const SizedBox(height: 24),

        // 4. DAFTAR FILE TERBARU
        _buildSectionHeader(
          'File Terbaru',
          onSeeAll: () => _showDummyActionToast('Lihat Semua File'),
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
            children: List.generate(_recentFiles.length, (index) {
              final file = _recentFiles[index];
              return Column(
                children: [
                  _buildFileItem(
                    name: file['name'].toString(),
                    uploader: file['uploader'].toString(),
                    size: file['size'].toString(),
                    date: file['date'].toString(),
                    extensionType: file['ext'].toString(),
                    onTap: () => _showDummyActionToast('Buka ${file['name']}'),
                    onMoreTap: () =>
                        _showDummyActionToast('Opsi ${file['name']}'),
                  ),
                  if (index < _recentFiles.length - 1)
                    Divider(
                      height: 1,
                      color: AppColors.borderLight,
                      indent: 16,
                      endIndent: 16,
                    ),
                ],
              );
            }),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  // WIDGET BANTUAN: Statistik Penyimpanan
  Widget _buildStorageStat(IconData icon, String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(value, style: AppTextStyles.cardTitle.copyWith(fontSize: 13)),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.cardSubtitle.copyWith(fontSize: 10)),
      ],
    );
  }

  // WIDGET BANTUAN: Header Seksi dengan 'Lihat Semua'
  Widget _buildSectionHeader(String title, {required VoidCallback onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.sectionTitle.copyWith(fontSize: 15)),
        GestureDetector(
          onTap: onSeeAll,
          child: Row(
            children: [
              Text(
                'Lihat Semua',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                size: 14,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // WIDGET BANTUAN: Item Folder
  Widget _buildFolderItem({
    required String name,
    required int files,
    required String size,
    required String date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.folder_rounded, color: AppColors.primary, size: 36),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$files file • $size',
                    style: AppTextStyles.cardSubtitle.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            Text(
              date,
              style: AppTextStyles.cardSubtitle.copyWith(
                fontSize: 10,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(width: 8),
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

  // WIDGET BANTUAN: Item File
  Widget _buildFileItem({
    required String name,
    required String uploader,
    required String size,
    required String date,
    required String extensionType,
    required VoidCallback onTap,
    required VoidCallback onMoreTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _getFileTypeIcon(extensionType),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.cardTitle.copyWith(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Diunggah oleh $uploader',
                    style: AppTextStyles.cardSubtitle.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  size,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: AppTextStyles.cardSubtitle.copyWith(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onMoreTap,
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(
                  Icons.more_vert_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET BANTUAN: Ikon Tipe File Ekstensi
  Widget _getFileTypeIcon(String ext) {
    Color bgColor;
    String label;
    IconData? icon;

    switch (ext) {
      case 'pdf':
        bgColor = const Color(0xFFEF4444); // Merah
        label = 'PDF';
        break;
      case 'doc':
        bgColor = const Color(0xFF3B82F6); // Biru
        label = 'W';
        break;
      case 'xls':
        bgColor = const Color(0xFF10B981); // Hijau
        label = 'X';
        break;
      case 'img':
        bgColor = const Color(0xFF8B5CF6); // Ungu
        label = '';
        icon = Icons.image_rounded;
        break;
      default:
        bgColor = Colors.grey;
        label = 'FILE';
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: icon != null
            ? Icon(icon, color: Colors.white, size: 20)
            : Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
