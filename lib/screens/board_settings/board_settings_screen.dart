import 'package:flutter/material.dart';

import '../../data/app_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/top_decor_blob.dart';

// Placeholder Import untuk file-file Tab Modular di folder tabs/
import 'tabs/files_tab.dart';
import 'tabs/general_tab.dart';
import 'tabs/lists_tab.dart';
import 'tabs/members_tab.dart';
import 'tabs/polling_tab.dart';
import 'tabs/reports_tab.dart';

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

  void _saveGeneralTabChanges() {
    // Dipanggil saat tombol centang kanan atas di-tap
    // Logika penyimpanan data umum di-handle oleh AppDataController
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pengaturan umum board berhasil disimpan'),
        duration: Duration(seconds: 2),
        backgroundColor: AppColors.primary,
      ),
    );
    Navigator.pop(context);
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
            'code': '',
          },
        );

        final bool isManager =
            AppDataController.instance.currentUserRole == 'Pembuat Board';

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              // 1. Ornamen Latar Belakang Tosca Kanan Atas
              const TopDecorBlob(size: 160),

              // 2. Konten Utama
              SafeArea(
                child: Column(
                  children: [
                    // Header (AppBar Custom)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 20,
                              color: AppColors.primary,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Column(
                            children: [
                              Text(
                                'Pengaturan Board',
                                style: AppTextStyles.screenTitle.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                board['title'] ?? widget.boardTitle,
                                style: AppTextStyles.cardSubtitle.copyWith(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.check_rounded,
                              color: AppColors.primary,
                              size: 26,
                            ),
                            tooltip: 'Simpan Perubahan Tab Umum',
                            onPressed: _saveGeneralTabChanges,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // TabBar Bergaya Kapsul (Pill Indicator) Sesuai Gambar
                    Container(
                      height: 38,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        indicator: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: AppColors.textSecondary,
                        labelStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        padding: EdgeInsets.zero,
                        labelPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                        ),
                        tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // TabBarView Memanggil Isi Masing-Masing Tab
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          GeneralTab(
                            boardId: widget.boardId,
                            isManager: isManager,
                          ),
                          MembersTab(
                            boardId: widget.boardId,
                            isManager: isManager,
                          ),
                          ListsTab(
                            boardId: widget.boardId,
                            isManager: isManager,
                          ),
                          PollingTab(
                            boardId: widget.boardId,
                            isManager: isManager,
                          ),
                          FilesTab(
                            boardId: widget.boardId,
                            isManager: isManager,
                          ),
                          ReportsTab(
                            boardId: widget.boardId,
                            isManager: isManager,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
