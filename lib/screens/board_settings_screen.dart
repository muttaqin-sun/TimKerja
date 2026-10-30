import 'package:flutter/material.dart';
import '../data/app_data.dart';
import '../theme/app_theme.dart';

class BoardSettingsScreen extends StatefulWidget {
  final String boardId;
  final String boardTitle;

  const BoardSettingsScreen({
    super.key,
    required this.boardId,
    required this.boardTitle,
  });

  @override
  State<BoardSettingsScreen> createState() => _BoardSettingsScreenState();
}

class _BoardSettingsScreenState extends State<BoardSettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabs = [
    'Umum',
    'Anggota',
    'List',
    'Polling',
    'File Umum',
    'Laporan',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppDataController.instance,
      builder: (context, _) {
        final board = AppDataController.instance.boards.firstWhere(
          (b) => b['id'] == widget.boardId,
          orElse: () => {
            'title': widget.boardTitle,
            'desc': '',
            'code': '',
            'lists': <String>[],
            'members': <Map<String, dynamic>>[],
          },
        );

        final bool isManager =
            AppDataController.instance.currentUserRole == 'Pembuat Board';

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: AppColors.textPrimary,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Pengaturan Board',
                  style: AppTextStyles.screenTitle.copyWith(fontSize: 17),
                ),
                Text(
                  board['title'] ?? widget.boardTitle,
                  style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.check_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
                tooltip: 'Simpan Perubahan',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pengaturan board berhasil disimpan'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  Navigator.pop(context);
                },
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.borderLight, width: 1),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: AppTextStyles.cardTitle.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: AppTextStyles.cardSubtitle.copyWith(
                    fontSize: 14,
                  ),
                  tabAlignment: TabAlignment.start,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
                ),
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildGeneralTab(board, isManager),
              _buildMembersTab(board, isManager),
              _buildListsTab(board, isManager),
              _buildPlaceholderTab(
                icon: Icons.how_to_vote_rounded,
                title: 'Polling / Voting',
                description:
                    'Buat pemungutan suara bersama anggota tim untuk menentukan keputusan proyek.',
              ),
              _buildPlaceholderTab(
                icon: Icons.folder_shared_rounded,
                title: 'File & Berkas Umum',
                description:
                    'Ruang penyimpanan berkas bersama yang dapat diakses oleh semua anggota board.',
              ),
              _buildPlaceholderTab(
                icon: Icons.assessment_rounded,
                title: 'Laporan Proyek',
                description:
                    'Filter dan unduh rangkuman performa proyek per periode mingguan/bulanan.',
              ),
            ],
          ),
          bottomNavigationBar: _buildDangerZone(board, isManager),
        );
      },
    );
  }

  Widget _buildGeneralTab(Map<String, dynamic> board, bool isManager) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionCard(
          title: 'Informasi Utama',
          icon: Icons.info_outline_rounded,
          children: [
            _buildTextField(
              label: 'Nama Board / Proyek',
              initialValue: board['title'] ?? '',
              enabled: isManager,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Deskripsi Proyek',
              initialValue: board['desc'] ?? '',
              maxLines: 3,
              enabled: isManager,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          title: 'Akses & Kode Undangan',
          icon: Icons.lock_outline_rounded,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kode Board',
                      style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      board['code'] ?? 'KODE-TIDAK-TERSEDIA',
                      style: AppTextStyles.cardTitle.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Kode ${board['code']} berhasil disalin!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('Salin'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.roundedMd,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMembersTab(Map<String, dynamic> board, bool isManager) {
    final List members = board['members'] ?? [];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daftar Anggota (${members.length})',
              style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
            ),
            if (isManager)
              TextButton.icon(
                onPressed: null,
                icon: Icon(Icons.person_add_alt_1_rounded, size: 18),
                label: Text('Undang'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        ...members.map((m) {
          final colorVal = m['color'] ?? 0xFF0F766E;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.roundedMd,
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(colorVal),
                  child: Text(
                    ((m['name'] as String?) ?? 'U').substring(0, 1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m['name'] ?? 'Anggota',
                        style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
                      ),
                      Text(
                        m['name'] == 'Ilham' ? 'Ketua Proyek' : 'Anggota Tim',
                        style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (isManager && m['name'] != 'Ilham')
                  IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outline_rounded,
                      color: AppColors.error,
                      size: 20,
                    ),
                    onPressed: () {},
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildListsTab(Map<String, dynamic> board, bool isManager) {
    final List<String> lists = List<String>.from(board['lists'] ?? []);
    final List<String> lockedLists = List<String>.from(
      board['lockedLists'] ?? [],
    );

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Struktur Kolom List (${lists.length})',
              style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
            ),
            if (isManager)
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Tambah List'),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
          ],
        ),
        const SizedBox(height: 12),
        ...lists.map((listTitle) {
          final bool isLocked = lockedLists.contains(listTitle);
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.roundedMd,
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.view_column_rounded,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    listTitle,
                    style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
                  ),
                ),
                if (isLocked)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_rounded,
                          size: 12,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Terkunci',
                          style: AppTextStyles.cardSubtitle.copyWith(
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                Icon(
                  Icons.drag_indicator_rounded,
                  color: AppColors.textMuted,
                  size: 20,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPlaceholderTab({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: AppTextStyles.screenTitle.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: AppTextStyles.cardSubtitle.copyWith(fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Fitur $title akan segera hadir!')),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.roundedPill,
                ),
              ),
              child: const Text('Lihat Pratinjau'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.roundedLg,
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [AppShadows.card],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.cardTitle.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.cardSubtitle.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: initialValue,
          enabled: enabled,
          maxLines: maxLines,
          style: AppTextStyles.inputText.copyWith(fontSize: 14),
          decoration: InputDecoration(
            isDense: true,
            filled: !enabled,
            fillColor: !enabled ? AppColors.surfaceMuted : AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: AppRadius.roundedMd,
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.roundedMd,
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.roundedMd,
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDangerZone(Map<String, dynamic> board, bool isManager) {
    if (!isManager) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              _showDeleteBoardDialog(board);
            },
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: const Text('Hapus Board Ini'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedMd),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteBoardDialog(Map<String, dynamic> board) {
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
              Navigator.pop(ctx);
              Navigator.pop(context);
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
