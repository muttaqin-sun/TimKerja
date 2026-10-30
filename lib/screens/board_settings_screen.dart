import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../services/pdf_report_service.dart';
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

  // Controller untuk Tab Umum
  late TextEditingController _titleController;
  late TextEditingController _descController;
  String _selectedPrivacy = 'Private';
  int? _selectedColor;

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

    final board = AppDataController.instance.boards.firstWhere(
      (b) => b['id'] == widget.boardId,
      orElse: () => {
        'id': widget.boardId,
        'title': widget.boardTitle,
        'desc': '',
        'code': 'KODE-BOARD',
        'privacy': 'Private',
        'color': 0xFF004D40,
        'lists': <String>[],
        'lockedLists': <String>[],
        'members': <Map<String, dynamic>>[],
        'polls': <Map<String, dynamic>>[],
        'files': <Map<String, dynamic>>[],
      },
    );
    _titleController = TextEditingController(
      text: board['title'] ?? widget.boardTitle,
    );
    _descController = TextEditingController(text: board['desc'] ?? '');
    _selectedPrivacy = board['privacy'] ?? 'Private';
    _selectedColor = board['color'] ?? 0xFF004D40;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descController.dispose();
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
            'id': widget.boardId,
            'title': widget.boardTitle,
            'desc': '',
            'code': 'KODE-BOARD',
            'privacy': 'Private',
            'color': 0xFF004D40,
            'lists': <String>[],
            'lockedLists': <String>[],
            'members': <Map<String, dynamic>>[],
            'polls': <Map<String, dynamic>>[],
            'files': <Map<String, dynamic>>[],
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
                  AppDataController.instance.updateBoardDetails(
                    widget.boardId,
                    title: _titleController.text.trim(),
                    desc: _descController.text.trim(),
                    privacy: _selectedPrivacy,
                    color: _selectedColor,
                  );
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
              _buildPollingTab(board, isManager),
              _buildFilesTab(board, isManager),
              _buildReportTab(board, isManager),
            ],
          ),
          bottomNavigationBar: _buildDangerZone(board, isManager),
        );
      },
    );
  }

  Widget _buildGeneralTab(Map<String, dynamic> board, bool isManager) {
    final List<Map<String, dynamic>> themeColors = [
      {'color': 0xFF004D40, 'name': 'Dark Teal'},
      {'color': 0xFF00A896, 'name': 'Teal Primary'},
      {'color': 0xFF0284C7, 'name': 'Ocean Blue'},
      {'color': 0xFF16A34A, 'name': 'Forest Green'},
      {'color': 0xFF9333EA, 'name': 'Royal Purple'},
      {'color': 0xFFF59E0B, 'name': 'Amber Orange'},
      {'color': 0xFFEF4444, 'name': 'Sunset Red'},
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionCard(
          title: 'Informasi Utama',
          icon: Icons.info_outline_rounded,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nama Board / Proyek',
                  style: AppTextStyles.cardSubtitle.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _titleController,
                  enabled: isManager,
                  style: AppTextStyles.inputText.copyWith(fontSize: 14),
                  decoration: InputDecoration(
                    isDense: true,
                    filled: !isManager,
                    fillColor: !isManager
                        ? AppColors.surfaceMuted
                        : AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.roundedMd,
                      borderSide: BorderSide(color: AppColors.borderLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadius.roundedMd,
                      borderSide: BorderSide(color: AppColors.borderLight),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: AppRadius.roundedMd,
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Deskripsi Proyek',
                  style: AppTextStyles.cardSubtitle.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _descController,
                  enabled: isManager,
                  maxLines: 3,
                  style: AppTextStyles.inputText.copyWith(fontSize: 14),
                  decoration: InputDecoration(
                    isDense: true,
                    filled: !isManager,
                    fillColor: !isManager
                        ? AppColors.surfaceMuted
                        : AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.roundedMd,
                      borderSide: BorderSide(color: AppColors.borderLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadius.roundedMd,
                      borderSide: BorderSide(color: AppColors.borderLight),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: AppRadius.roundedMd,
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          title: 'Warna Tema & Privasi',
          icon: Icons.palette_outlined,
          children: [
            Text(
              'Warna Utama Board',
              style: AppTextStyles.cardSubtitle.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: themeColors.map((tc) {
                  final int colVal = tc['color'];
                  final bool isSelected = _selectedColor == colVal;
                  return GestureDetector(
                    onTap: isManager
                        ? () {
                            setState(() {
                              _selectedColor = colVal;
                            });
                          }
                        : null,
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Color(colVal),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 2.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Color(colVal).withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              size: 20,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Visibilitas & Privasi',
              style: AppTextStyles.cardSubtitle.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildPrivacyOption(
                  title: 'Private',
                  desc: 'Hanya anggota yang diundang',
                  icon: Icons.lock_outline_rounded,
                  isSelected: _selectedPrivacy == 'Private',
                  onTap: isManager
                      ? () => setState(() => _selectedPrivacy = 'Private')
                      : null,
                ),
                const SizedBox(width: 12),
                _buildPrivacyOption(
                  title: 'Workspace',
                  desc: 'Seluruh anggota organisasi',
                  icon: Icons.groups_outlined,
                  isSelected: _selectedPrivacy == 'Workspace',
                  onTap: isManager
                      ? () => setState(() => _selectedPrivacy = 'Workspace')
                      : null,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          title: 'Akses & Kode Undangan',
          icon: Icons.key_outlined,
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
                        content: Text(
                          'Kode ${board['code']} berhasil disalin!',
                        ),
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
        const SizedBox(height: 24),
        if (isManager)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                AppDataController.instance.updateBoardDetails(
                  widget.boardId,
                  title: _titleController.text.trim(),
                  desc: _descController.text.trim(),
                  privacy: _selectedPrivacy,
                  color: _selectedColor,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pengaturan board berhasil disimpan'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
              label: const Text('Simpan Pengaturan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                textStyle: AppTextStyles.cardTitle.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.roundedMd,
                ),
                elevation: 0,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPrivacyOption({
    required String title,
    required String desc,
    required IconData icon,
    required bool isSelected,
    required VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primarySurface : AppColors.surface,
            borderRadius: AppRadius.roundedMd,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.borderLight,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: isSelected ? AppColors.primary : AppColors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: AppTextStyles.cardTitle.copyWith(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w600,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: AppTextStyles.cardSubtitle.copyWith(fontSize: 11),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daftar Anggota (${members.length})',
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
                ),
                Text(
                  'Anggota yang memiliki akses board ini',
                  style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12),
                ),
              ],
            ),
            if (isManager)
              ElevatedButton.icon(
                onPressed: () => _showInviteMemberDialog(board),
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
                label: const Text('Undang'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  textStyle: AppTextStyles.cardTitle.copyWith(fontSize: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.roundedPill,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),

        if (members.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.roundedLg,
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.people_outline_rounded,
                      size: 36,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Belum Ada Anggota',
                    style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Gunakan tombol Undang di atas atau bagikan kode board untuk menambahkan tim.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
          )
        else
          ...members.map((m) {
            final colorVal = m['color'] ?? 0xFF0F766E;
            final String memberName = m['name'] ?? 'Anggota';
            final String currentUserName =
                AppDataController.instance.currentUserProfile['name'] ??
                'Pengguna';
            final String role = m['role'] ??
                (isManager && memberName == currentUserName
                    ? 'Pembuat Board'
                    : 'Anggota');
            final bool isOwner = role == 'Pembuat Board';

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.roundedMd,
                border: Border.all(color: AppColors.borderLight),
                boxShadow: const [AppShadows.card],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(colorVal),
                    child: Text(
                      memberName.isNotEmpty
                          ? memberName.substring(0, 1).toUpperCase()
                          : 'U',
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
                          memberName,
                          style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
                        ),
                        Text(
                          isOwner ? 'Ketua Proyek' : 'Anggota Tim',
                          style: AppTextStyles.cardSubtitle.copyWith(
                            fontSize: 12,
                            color: isOwner
                                ? AppColors.primary
                                : AppColors.textMuted,
                            fontWeight: isOwner
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isManager && !isOwner)
                    IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline_rounded,
                        color: AppColors.error,
                        size: 20,
                      ),
                      tooltip: 'Keluarkan Anggota',
                      onPressed: () {
                        _showRemoveMemberDialog(memberName);
                      },
                    ),
                ],
              ),
            );
          }),
      ],
    );
  }

  void _showInviteMemberDialog(Map<String, dynamic> board) {
    final TextEditingController nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
        title: Text(
          'Undang Anggota',
          style: AppTextStyles.screenTitle.copyWith(fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Opsi 1: Bagikan Kode Undangan',
              style: AppTextStyles.cardTitle.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: AppRadius.roundedMd,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    board['code'] ?? 'KODE-BOARD',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 15,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Kode ${board['code']} disalin!'),
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.copy_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Opsi 2: Tambahkan Langsung',
              style: AppTextStyles.cardTitle.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                hintText: 'Nama lengkap anggota...',
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                AppDataController.instance.addBoardMember(
                  widget.boardId,
                  nameCtrl.text.trim(),
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${nameCtrl.text.trim()} berhasil ditambahkan',
                    ),
                  ),
                );
              }
            },
            child: const Text('Tambahkan'),
          ),
        ],
      ),
    );
  }

  void _showRemoveMemberDialog(String memberName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
        title: Text(
          'Keluarkan Anggota?',
          style: AppTextStyles.screenTitle.copyWith(
            fontSize: 18,
            color: AppColors.error,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin mengeluarkan "$memberName" dari proyek ini?',
          style: AppTextStyles.cardSubtitle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              AppDataController.instance.removeBoardMember(
                widget.boardId,
                memberName,
              );
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Keluarkan'),
          ),
        ],
      ),
    );
  }

  Widget _buildListsTab(Map<String, dynamic> board, bool isManager) {
    final List<String> lists = List<String>.from(board['lists'] ?? []);
    final List<String> lockedLists = List<String>.from(
      board['lockedLists'] ?? [],
    );

    final allTasks = AppDataController.instance.tasks
        .where((t) => t['boardId'] == widget.boardId)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Struktur Kolom List (${lists.length})',
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
                ),
                Text(
                  isManager
                      ? 'Tahan dan geser untuk mengatur urutan'
                      : 'Daftar kolom kanban aktif',
                  style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12),
                ),
              ],
            ),
            if (isManager)
              ElevatedButton.icon(
                onPressed: () => _showAddListDialog(),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Tambah'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  textStyle: AppTextStyles.cardTitle.copyWith(fontSize: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.roundedPill,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (lists.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.roundedLg,
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.view_column_outlined,
                    size: 40,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Belum ada list di board ini',
                    style: AppTextStyles.cardSubtitle,
                  ),
                ],
              ),
            ),
          )
        else
          Theme(
            data: Theme.of(context).copyWith(
              canvasColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            child: ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: lists.length,
              buildDefaultDragHandles: false,
              onReorder: (oldIndex, newIndex) {
                if (isManager) {
                  AppDataController.instance.reorderBoardLists(
                    widget.boardId,
                    oldIndex,
                    newIndex,
                  );
                }
              },
              itemBuilder: (context, index) {
                final listTitle = lists[index];
                final bool isLocked = lockedLists.contains(listTitle);
                final int taskCount = allTasks
                    .where((t) => t['listName'] == listTitle)
                    .length;

                IconData listIcon = Icons.view_kanban_outlined;
                Color listIconColor = AppColors.primary;
                final lowerTitle = listTitle.toLowerCase();
                if (isLocked) {
                  listIcon = Icons.lock_outline_rounded;
                  listIconColor = AppColors.textMuted;
                } else if (lowerTitle.contains('selesai') ||
                    lowerTitle.contains('done')) {
                  listIcon = Icons.check_circle_outline_rounded;
                  listIconColor = const Color(0xFF16A34A);
                } else if (lowerTitle.contains('revisi') ||
                    lowerTitle.contains('review')) {
                  listIcon = Icons.rate_review_outlined;
                  listIconColor = const Color(0xFFF59E0B);
                } else if (lowerTitle.contains('projek') ||
                    lowerTitle.contains('progress') ||
                    lowerTitle.contains('tahap')) {
                  listIcon = Icons.pending_actions_rounded;
                  listIconColor = const Color(0xFF0284C7);
                } else if (lowerTitle.contains('tugas') ||
                    lowerTitle.contains('todo')) {
                  listIcon = Icons.assignment_outlined;
                  listIconColor = const Color(0xFF0F766E);
                }

                return Container(
                  key: ValueKey('list_$listTitle'),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.roundedMd,
                    border: Border.all(
                      color: isLocked
                          ? AppColors.textMuted.withValues(alpha: 0.3)
                          : AppColors.borderLight,
                    ),
                    boxShadow: const [AppShadows.card],
                  ),
                  child: Row(
                    children: [
                      // Icon Status Kolom
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isLocked
                              ? AppColors.surfaceMuted
                              : listIconColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          listIcon,
                          color: listIconColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    listTitle,
                                    style: AppTextStyles.cardTitle.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isLocked) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceMuted,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Terkunci',
                                      style: AppTextStyles.cardSubtitle
                                          .copyWith(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textMuted,
                                          ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$taskCount tugas di kolom ini',
                              style: AppTextStyles.cardSubtitle.copyWith(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Action buttons
                      if (isManager) ...[
                        // Toggle Lock
                        IconButton(
                          icon: Icon(
                            isLocked
                                ? Icons.lock_rounded
                                : Icons.lock_open_rounded,
                            size: 18,
                            color: isLocked
                                ? AppColors.error
                                : AppColors.textMuted,
                          ),
                          tooltip: isLocked ? 'Buka Kunci' : 'Kunci List',
                          onPressed: () {
                            AppDataController.instance.toggleListLock(
                              widget.boardId,
                              listTitle,
                            );
                          },
                        ),
                        // Opsi Menu (Rename / Delete)
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert_rounded,
                            size: 18,
                            color: AppColors.textMuted,
                          ),
                          onSelected: (val) {
                            if (val == 'rename') {
                              _showRenameListDialog(listTitle);
                            } else if (val == 'delete') {
                              _showDeleteListDialog(listTitle);
                            }
                          },
                          itemBuilder: (ctx) => [
                            PopupMenuItem(
                              value: 'rename',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit_outlined,
                                    size: 16,
                                    color: AppColors.textPrimary,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('Ubah Nama'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.delete_outline_rounded,
                                    size: 16,
                                    color: AppColors.error,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Hapus Kolom',
                                    style: TextStyle(color: AppColors.error),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // Drag Handle
                        ReorderableDragStartListener(
                          index: index,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 4, right: 4),
                            child: Icon(
                              Icons.drag_indicator_rounded,
                              color: AppColors.textMuted,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // Dialog Tambah List
  void _showAddListDialog() {
    final TextEditingController ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
        title: Text(
          'Tambah List Baru',
          style: AppTextStyles.screenTitle.copyWith(fontSize: 18),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nama kolom (Contoh: Testing, Done)...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                AppDataController.instance.addBoardList(
                  widget.boardId,
                  ctrl.text.trim(),
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  // Dialog Ubah Nama List
  void _showRenameListDialog(String oldName) {
    final TextEditingController ctrl = TextEditingController(text: oldName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
        title: Text(
          'Ubah Nama List',
          style: AppTextStyles.screenTitle.copyWith(fontSize: 18),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nama list...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty && ctrl.text.trim() != oldName) {
                AppDataController.instance.renameBoardList(
                  widget.boardId,
                  oldName,
                  ctrl.text.trim(),
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // Dialog Hapus List
  void _showDeleteListDialog(String listName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
        title: Text(
          'Hapus Kolom List?',
          style: AppTextStyles.screenTitle.copyWith(
            fontSize: 18,
            color: AppColors.error,
          ),
        ),
        content: Text(
          'Semua task di dalam list "$listName" juga akan ikut terhapus secara permanen.',
          style: AppTextStyles.cardSubtitle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              AppDataController.instance.deleteBoardList(
                widget.boardId,
                listName,
              );
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus Kolom'),
          ),
        ],
      ),
    );
  }

  // TAB POLLING
  Widget _buildPollingTab(Map<String, dynamic> board, bool isManager) {
    final List polls = board['polls'] ?? [];
    final currentUserName =
        AppDataController.instance.currentUserProfile['name'] ?? 'Pengguna';

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pemungutan Suara (${polls.length})',
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
                ),
                Text(
                  'Polling keputusan bersama tim',
                  style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => _showCreatePollDialog(),
              icon: const Icon(Icons.add_rounded, size: 15),
              label: const Text('Buat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                textStyle: AppTextStyles.cardTitle.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.roundedPill,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (polls.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.roundedLg,
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.how_to_vote_outlined,
                      size: 36,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Belum Ada Polling Aktif',
                    style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Buat voting baru untuk menyepakati keputusan proyek bersama anggota tim.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: () => _showCreatePollDialog(),
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Buat Polling'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.roundedPill,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...polls.map((poll) {
            final String pollId = poll['id'];
            final String question = poll['question'] ?? '';
            final String creator = poll['creator'] ?? 'Anggota';
            final bool isClosed = poll['isClosed'] ?? false;
            final List options = poll['options'] ?? [];

            // Hitung total vote
            int totalVotes = 0;
            for (var opt in options) {
              totalVotes += ((opt['votes'] as List?)?.length ?? 0);
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.roundedLg,
                border: Border.all(
                  color: isClosed
                      ? AppColors.borderLight
                      : AppColors.primary.withValues(alpha: 0.35),
                ),
                boxShadow: const [AppShadows.card],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isClosed
                                  ? AppColors.surfaceMuted
                                  : AppColors.primarySurface,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isClosed ? 'Ditutup' : 'Aktif',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isClosed
                                    ? AppColors.textMuted
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Oleh $creator',
                            style: AppTextStyles.cardSubtitle.copyWith(
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      if (isManager || creator == currentUserName)
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_horiz_rounded,
                            size: 18,
                            color: AppColors.textMuted,
                          ),
                          onSelected: (val) {
                            if (val == 'toggle_status') {
                              AppDataController.instance.togglePollStatus(
                                widget.boardId,
                                pollId,
                              );
                            } else if (val == 'delete') {
                              AppDataController.instance.deletePoll(
                                widget.boardId,
                                pollId,
                              );
                            }
                          },
                          itemBuilder: (ctx) => [
                            PopupMenuItem(
                              value: 'toggle_status',
                              child: Text(
                                isClosed ? 'Buka Kembali' : 'Tutup Polling',
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text(
                                'Hapus Polling',
                                style: TextStyle(color: AppColors.error),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    question,
                    style: AppTextStyles.cardTitle.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Opsi Polling
                  ...List.generate(options.length, (optIdx) {
                    final opt = options[optIdx];
                    final String optText = opt['text'] ?? '';
                    final List votes = opt['votes'] ?? [];
                    final bool userVotedThis = votes.contains(currentUserName);
                    final double percentage = totalVotes > 0
                        ? (votes.length / totalVotes)
                        : 0.0;

                    return GestureDetector(
                      onTap: isClosed
                          ? null
                          : () {
                              AppDataController.instance.votePoll(
                                widget.boardId,
                                pollId,
                                optIdx,
                              );
                            },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: AppRadius.roundedMd,
                          border: Border.all(
                            color: userVotedThis
                                ? AppColors.primary
                                : AppColors.borderLight,
                            width: userVotedThis ? 1.5 : 1,
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Progress bar suara
                            Positioned.fill(
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: percentage,
                                child: Container(
                                  color: userVotedThis
                                      ? AppColors.primary.withValues(
                                          alpha: 0.18,
                                        )
                                      : AppColors.surfaceMuted,
                                ),
                              ),
                            ),
                            // Teks opsi & info vote
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        userVotedThis
                                            ? Icons.check_circle_rounded
                                            : Icons
                                                  .radio_button_unchecked_rounded,
                                        size: 18,
                                        color: userVotedThis
                                            ? AppColors.primary
                                            : AppColors.textMuted,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        optText,
                                        style: AppTextStyles.cardTitle.copyWith(
                                          fontSize: 13,
                                          fontWeight: userVotedThis
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${votes.length} (${(percentage * 100).toStringAsFixed(0)}%)',
                                    style: AppTextStyles.cardSubtitle.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: userVotedThis
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$totalVotes suara terkumpul',
                        style: AppTextStyles.cardSubtitle.copyWith(
                          fontSize: 11,
                        ),
                      ),
                      if (!isClosed)
                        Text(
                          'Ketuk opsi untuk memilih',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  // Dialog Buat Polling Baru
  void _showCreatePollDialog() {
    final TextEditingController questionCtrl = TextEditingController();
    final List<TextEditingController> optionCtrls = [
      TextEditingController(),
      TextEditingController(),
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
            title: Text(
              'Buat Polling Baru',
              style: AppTextStyles.screenTitle.copyWith(fontSize: 18),
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pertanyaan / Agenda Voting',
                      style: AppTextStyles.cardSubtitle.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: questionCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Misal: Tentukan deadline tahap 1...',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Pilihan Opsi Jawaban',
                      style: AppTextStyles.cardSubtitle.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(optionCtrls.length, (idx) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: optionCtrls[idx],
                                decoration: InputDecoration(
                                  hintText: 'Opsi ${idx + 1}',
                                  isDense: true,
                                ),
                              ),
                            ),
                            if (optionCtrls.length > 2)
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle_outline_rounded,
                                  color: AppColors.error,
                                  size: 18,
                                ),
                                onPressed: () {
                                  setDialogState(() {
                                    optionCtrls.removeAt(idx);
                                  });
                                },
                              ),
                          ],
                        ),
                      );
                    }),
                    if (optionCtrls.length < 5)
                      TextButton.icon(
                        onPressed: () {
                          setDialogState(() {
                            optionCtrls.add(TextEditingController());
                          });
                        },
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('Tambah Opsi Lain'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  final q = questionCtrl.text.trim();
                  final validOpts = optionCtrls
                      .map((c) => c.text.trim())
                      .where((t) => t.isNotEmpty)
                      .toList();

                  if (q.isNotEmpty && validOpts.length >= 2) {
                    AppDataController.instance.addPoll(
                      widget.boardId,
                      q,
                      validOpts,
                    );
                    Navigator.pop(ctx);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Masukkan pertanyaan dan minimal 2 opsi pilihan.',
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Buat Polling'),
              ),
            ],
          );
        },
      ),
    );
  }

  // TAB FILE UMUM
  Widget _buildFilesTab(Map<String, dynamic> board, bool isManager) {
    final List files = board['files'] ?? [];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Berkas Proyek (${files.length})',
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
                ),
                Text(
                  'Ruang file sharing bersama anggota tim',
                  style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => _showUploadFileDialog(),
              icon: const Icon(Icons.upload_file_rounded, size: 16),
              label: const Text('Unggah Berkas'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                textStyle: AppTextStyles.cardTitle.copyWith(fontSize: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.roundedPill,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (files.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.roundedLg,
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.folder_shared_outlined,
                      size: 36,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Belum Ada Berkas Bersama',
                    style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Bagikan dokumen panduan, referensi, atau file aset agar tidak tercecer.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: () => _showUploadFileDialog(),
                    icon: const Icon(Icons.upload_file_rounded, size: 16),
                    label: const Text('Unggah Berkas'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.roundedPill,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...files.map((file) {
            final String fileId = file['id'];
            final String name = file['name'] ?? 'Dokumen';
            final String size = file['size'] ?? '0 KB';
            final String uploader = file['uploadedBy'] ?? 'Anggota';
            final String date = file['uploadedAt'] ?? 'Baru saja';
            final String ext = file['extension'] ?? 'file';

            IconData fileIcon;
            Color iconColor;
            if (ext.contains('pdf')) {
              fileIcon = Icons.picture_as_pdf_rounded;
              iconColor = const Color(0xFFEF4444);
            } else if (ext.contains('fig') ||
                ext.contains('png') ||
                ext.contains('jpg')) {
              fileIcon = Icons.image_rounded;
              iconColor = const Color(0xFF0284C7);
            } else if (ext.contains('doc') || ext.contains('docx')) {
              fileIcon = Icons.description_rounded;
              iconColor = const Color(0xFF2563EB);
            } else if (ext.contains('zip') || ext.contains('rar')) {
              fileIcon = Icons.folder_zip_rounded;
              iconColor = const Color(0xFFF59E0B);
            } else {
              fileIcon = Icons.insert_drive_file_rounded;
              iconColor = AppColors.primary;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.roundedMd,
                border: Border.all(color: AppColors.borderLight),
                boxShadow: const [AppShadows.card],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(fileIcon, color: iconColor, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '$size • Oleh $uploader • $date',
                          style: AppTextStyles.cardSubtitle.copyWith(
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.download_rounded,
                      size: 20,
                      color: AppColors.textMuted,
                    ),
                    tooltip: 'Unduh Berkas',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Mengunduh $name...')),
                      );
                    },
                  ),
                  if (isManager ||
                      uploader ==
                          AppDataController.instance.currentUserProfile['name'])
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: 20,
                        color: AppColors.error,
                      ),
                      tooltip: 'Hapus Berkas',
                      onPressed: () {
                        AppDataController.instance.deleteBoardFile(
                          widget.boardId,
                          fileId,
                        );
                      },
                    ),
                ],
              ),
            );
          }),
      ],
    );
  }

  void _showUploadFileDialog() {
    final TextEditingController nameCtrl = TextEditingController();
    String selectedExt = 'pdf';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
            title: Text(
              'Unggah Berkas Baru',
              style: AppTextStyles.screenTitle.copyWith(fontSize: 18),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nama Berkas',
                  style: AppTextStyles.cardSubtitle.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Contoh: Laporan-Riset-UIUX',
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Format Berkas',
                  style: AppTextStyles.cardSubtitle.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedExt,
                  decoration: const InputDecoration(isDense: true),
                  items: const [
                    DropdownMenuItem(
                      value: 'pdf',
                      child: Text('PDF Document (.pdf)'),
                    ),
                    DropdownMenuItem(
                      value: 'fig',
                      child: Text('Figma / Image Design (.fig, .png)'),
                    ),
                    DropdownMenuItem(
                      value: 'docx',
                      child: Text('Word Document (.docx)'),
                    ),
                    DropdownMenuItem(
                      value: 'zip',
                      child: Text('Archive File (.zip)'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() {
                        selectedExt = val;
                      });
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  final n = nameCtrl.text.trim();
                  if (n.isNotEmpty) {
                    final fullName = n.contains('.') ? n : '$n.$selectedExt';
                    AppDataController.instance.addBoardFile(
                      widget.boardId,
                      fullName,
                      '1.8 MB',
                      extension: selectedExt,
                    );
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Unggah'),
              ),
            ],
          );
        },
      ),
    );
  }

  // TAB LAPORAN PROYEK
  Widget _buildReportTab(Map<String, dynamic> board, bool isManager) {
    final boardTasks = AppDataController.instance.tasks
        .where((t) => t['boardId'] == widget.boardId)
        .toList();

    final completedTasks = boardTasks.where((t) => t['isDone'] == true).length;
    final inProgressTasks = boardTasks
        .where((t) => t['status'] == 'In Progress')
        .length;
    final pendingTasks = boardTasks.length - completedTasks;
    final int progressPercent = boardTasks.isEmpty
        ? 0
        : ((completedTasks / boardTasks.length) * 100).round();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Laporan & Ringkasan Performa',
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
                ),
                Text(
                  'Statistik penyelesaian proyek ini',
                  style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () async {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Menyiapkan laporan PDF...'),
                    duration: Duration(seconds: 1),
                  ),
                );
                try {
                  await PdfReportService.generateAndPreviewBoardReport(
                    boardId: widget.boardId,
                    boardTitle: board['title'] ?? widget.boardTitle,
                  );
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal membuat PDF: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
              label: const Text('Unduh PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                textStyle: AppTextStyles.cardTitle.copyWith(fontSize: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.roundedPill,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Progress Bar Card
        Container(
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tingkat Penyelesaian Keseluruhan',
                    style: AppTextStyles.cardTitle.copyWith(fontSize: 13),
                  ),
                  Text(
                    '$progressPercent%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: boardTasks.isEmpty
                      ? 0
                      : (completedTasks / boardTasks.length),
                  backgroundColor: AppColors.surfaceMuted,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                  minHeight: 10,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    'Total Tugas',
                    '${boardTasks.length}',
                    AppColors.textPrimary,
                  ),
                  _buildStatItem(
                    'Selesai',
                    '$completedTasks',
                    AppColors.primary,
                  ),
                  _buildStatItem(
                    'In Progress',
                    '$inProgressTasks',
                    const Color(0xFF0284C7),
                  ),
                  _buildStatItem(
                    'Tertunda',
                    '$pendingTasks',
                    const Color(0xFFEF4444),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Info Anggota & Kontribusi Singkat
        _buildSectionCard(
          title: 'Kontribusi Anggota Tim',
          icon: Icons.pie_chart_outline_rounded,
          children: [
            ...((board['members'] ?? []) as List).map((member) {
              final memberName = member['name'] ?? 'Anggota';
              final colorVal = member['color'] ?? 0xFF0F766E;

              // Hitung task yang assigned ke member ini
              final memberTasks = boardTasks.where((t) {
                final membersInTask = (t['members'] as List?) ?? [];
                return membersInTask.any((m) => m['name'] == memberName);
              }).toList();

              final doneCount = memberTasks
                  .where((t) => t['isDone'] == true)
                  .length;
              final double memberRatio = boardTasks.isEmpty
                  ? 0.0
                  : (doneCount / boardTasks.length);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: Color(colorVal),
                              child: Text(
                                memberName.isNotEmpty
                                    ? memberName[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              memberName,
                              style: AppTextStyles.cardTitle.copyWith(
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '$doneCount dari ${memberTasks.length} tugas (${(memberRatio * 100).toStringAsFixed(0)}%)',
                          style: AppTextStyles.cardSubtitle.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: memberRatio,
                        backgroundColor: AppColors.surfaceMuted,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(colorVal),
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.cardSubtitle.copyWith(fontSize: 11)),
      ],
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
