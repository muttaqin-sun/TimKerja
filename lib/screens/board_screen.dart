import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/app_data.dart';
import '../services/pdf_report_service.dart';
import '../theme/app_theme.dart';
import 'board_settings/board_settings_screen.dart';
import 'task_detail_screen.dart';

class BoardScreen extends StatefulWidget {
  final String boardId;
  final String boardTitle;
  const BoardScreen({
    super.key,
    required this.boardId,
    required this.boardTitle,
  });

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  final ScrollController _horizontalScrollController = ScrollController();
  Timer? _autoScrollTimer;
  double _autoScrollSpeed = 0.0;
  String? _hoveredListName;
  String? _draggingTaskId;

  @override
  void dispose() {
    _stopAutoScroll();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  // Setengah lebar kartu (kartu berukuran 256 px lebar)
  static const double _cardHalfWidth = 128.0;

  void _handleDragAutoScroll(Offset globalPosition) {
    if (_draggingTaskId == null) {
      _stopAutoScroll();
      return;
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final edgeThreshold = screenWidth * 0.18; // 18 % dari batas kiri & kanan

    final dx = globalPosition.dx;
    // Hitung batas kiri & kanan visual kartu berdasarkan anchor (tengah kartu)
    final leftEdge = dx - _cardHalfWidth;
    final rightEdge = dx + _cardHalfWidth;

    if (leftEdge < edgeThreshold) {
      // Dekat batas kiri → scroll ke kiri
      final proximity = (edgeThreshold - leftEdge) / edgeThreshold; // 0‑1
      _autoScrollSpeed = -((proximity * 14) + 6);
      _startAutoScroll();
    } else if (rightEdge > screenWidth - edgeThreshold) {
      // Dekat batas kanan → scroll ke kanan
      final proximity =
          (rightEdge - (screenWidth - edgeThreshold)) / edgeThreshold;
      _autoScrollSpeed = (proximity * 14) + 6;
      _startAutoScroll();
    } else {
      _stopAutoScroll();
    }
  }

  void _startAutoScroll() {
    if (_autoScrollTimer != null && _autoScrollTimer!.isActive) return;

    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 20), (
      timer,
    ) {
      if (!_horizontalScrollController.hasClients || _autoScrollSpeed == 0.0) {
        _stopAutoScroll();
        return;
      }

      final current = _horizontalScrollController.offset;
      final max = _horizontalScrollController.position.maxScrollExtent;
      final target = (current + _autoScrollSpeed).clamp(0.0, max);

      if (target != current) {
        _horizontalScrollController.jumpTo(target);
      } else {
        _stopAutoScroll();
      }
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
    _autoScrollSpeed = 0.0;
  }

  // Modal Tambah Task Baru
  void _showAddTaskModal(String listName) {
    final TextEditingController titleCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tambah Task ($listName)',
                  style: AppTextStyles.screenTitle.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleCtrl,
                  style: AppTextStyles.inputText,
                  decoration: const InputDecoration(
                    hintText: 'Nama tugas baru...',
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (titleCtrl.text.trim().isNotEmpty) {
                      AppDataController.instance.addTask(
                        widget.boardId,
                        titleCtrl.text.trim(),
                        listName,
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Modal Tambah List/Kolom Baru
  void _showAddListModal() {
    final TextEditingController listNameCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Buat List Baru',
                  style: AppTextStyles.screenTitle.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: listNameCtrl,
                  style: AppTextStyles.inputText,
                  decoration: const InputDecoration(
                    hintText: 'Contoh: Testing, Review, Released...',
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (listNameCtrl.text.trim().isNotEmpty) {
                      AppDataController.instance.addBoardList(
                        widget.boardId,
                        listNameCtrl.text.trim(),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Buat List'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Modal Edit Nama List
  void _showEditListModal(String oldListName) {
    final TextEditingController ctrl = TextEditingController(text: oldListName);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Nama List',
                  style: AppTextStyles.screenTitle.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ctrl,
                  style: AppTextStyles.inputText,
                  decoration: const InputDecoration(
                    hintText: 'Masukkan nama list baru...',
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (ctrl.text.trim().isNotEmpty) {
                      AppDataController.instance.renameBoardList(
                        widget.boardId,
                        oldListName,
                        ctrl.text.trim(),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Simpan Perubahan'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Dialog Konfirmasi Hapus List
  void _showDeleteListConfirmation(String listName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Hapus List?',
            style: AppTextStyles.cardTitle.copyWith(fontSize: 18),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus kolom "$listName"? Semua task di dalamnya juga akan terhapus secara permanen.',
            style: AppTextStyles.cardSubtitle,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () {
                AppDataController.instance.deleteBoardList(
                  widget.boardId,
                  listName,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('List berhasil dihapus')),
                );
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  // Modal Opsi List (Titik Tiga)
  void _showListOptionsModal(
    BuildContext context,
    String listTitle,
    bool isManager,
    bool isLocked,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Opsi: $listTitle',
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 16),

                // Edit (Manager)
                if (isManager)
                  ListTile(
                    leading: Icon(
                      Icons.edit_outlined,
                      color: AppColors.textPrimary,
                    ),
                    title: Text(
                      'Edit Nama List',
                      style: AppTextStyles.inputText,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showEditListModal(listTitle);
                    },
                  ),

                // Urutkan (Semua)
                ListTile(
                  leading: Icon(
                    Icons.sort_rounded,
                    color: AppColors.textPrimary,
                  ),
                  title: Text(
                    'Urutkan Task (Selesai ke Bawah)',
                    style: AppTextStyles.inputText,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    AppDataController.instance.sortTasksByStatus(
                      widget.boardId,
                      listTitle,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tugas berhasil diurutkan')),
                    );
                  },
                ),

                // Kunci/Buka Kunci (Manager)
                if (isManager)
                  ListTile(
                    leading: Icon(
                      isLocked
                          ? Icons.lock_open_rounded
                          : Icons.lock_outline_rounded,
                      color: AppColors.textPrimary,
                    ),
                    title: Text(
                      isLocked ? 'Buka Kunci List' : 'Kunci List',
                      style: AppTextStyles.inputText,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      AppDataController.instance.toggleListLock(
                        widget.boardId,
                        listTitle,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isLocked
                                ? 'Kunci list "$listTitle" telah dibuka'
                                : 'List "$listTitle" berhasil dikunci',
                          ),
                        ),
                      );
                    },
                  ),

                // Hapus (Manager)
                if (isManager)
                  ListTile(
                    leading: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.error,
                    ),
                    title: Text(
                      'Hapus List',
                      style: AppTextStyles.inputText.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showDeleteListConfirmation(listTitle);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isManager =
        AppDataController.instance.currentUserRole == 'Pembuat Board';

    return ListenableBuilder(
      listenable: AppDataController.instance,
      builder: (context, _) {
        final board = AppDataController.instance.boards.firstWhere(
          (b) => b['id'] == widget.boardId,
          orElse: () => {'title': widget.boardTitle, 'lists': <String>[]},
        );
        final List<String> boardLists = List<String>.from(board['lists'] ?? []);
        final List<String> lockedLists = List<String>.from(
          board['lockedLists'] ?? [],
        );

        final List<Map<String, dynamic>> boardTasks = AppDataController
            .instance
            .tasks
            .where((t) => t['boardId'] == widget.boardId)
            .map<Map<String, dynamic>>(
              (task) => Map<String, dynamic>.from(task),
            )
            .toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: AppColors.textPrimary,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              widget.boardTitle,
              style: AppTextStyles.screenTitle.copyWith(fontSize: 18),
            ),
            centerTitle: true,
            actions: [
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_horiz_rounded,
                  color: AppColors.textPrimary,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: AppColors.surface,
                onSelected: (value) async {
                  if (value == 'download_pdf') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Menyiapkan laporan PDF...'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                    try {
                      await PdfReportService.generateAndPreviewBoardReport(
                        boardId: widget.boardId,
                        boardTitle: widget.boardTitle,
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
                  } else if (value == 'settings') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BoardSettingsScreen(
                          boardId: widget.boardId,
                          boardTitle: widget.boardTitle,
                        ),
                      ),
                    );
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'download_pdf',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.picture_as_pdf_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Unduh Laporan PDF',
                          style: AppTextStyles.cardTitle.copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(
                          Icons.settings_outlined,
                          size: 18,
                          color: AppColors.textPrimary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Pengaturan Board',
                          style: AppTextStyles.cardTitle.copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    // Card Info Board (DENGAN FITUR COPY KODE)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.roundedLg,
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primarySurface,
                              borderRadius: AppRadius.roundedMd,
                            ),
                            child: const Icon(
                              Icons.folder_rounded,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.boardTitle,
                                  style: AppTextStyles.cardTitle.copyWith(
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      '${boardLists.length} lists • ${boardTasks.length} tasks',
                                      style: AppTextStyles.cardSubtitle,
                                    ),
                                    // MENAMPILKAN KODE BOARD (Khusus Pembuat Board)
                                    if (isManager && board['code'] != null) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        height: 12,
                                        width: 1,
                                        color: AppColors.border,
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Kode Board ${board['code']} disalin!',
                                              ),
                                            ),
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.copy_rounded,
                                              size: 12,
                                              color: AppColors.primary,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              board['code'],
                                              style: AppTextStyles.cardSubtitle
                                                  .copyWith(
                                                    color: AppColors.primary,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Search Bar
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.roundedPill,
                        border: Border.all(
                          color: AppColors.borderLight,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            color: AppColors.textMuted,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Cari task...',
                                hintStyle: AppTextStyles.cardSubtitle.copyWith(
                                  fontSize: 13,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                              ),
                              style: AppTextStyles.cardTitle.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.filter_list_rounded,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: DragTarget<Map<String, dynamic>>(
                  onWillAcceptWithDetails: (details) => true,
                  onMove: (details) {
                    _handleDragAutoScroll(details.offset);
                  },
                  onLeave: (data) {
                    _stopAutoScroll();
                  },
                  builder: (context, candidateData, rejectedData) {
                    return ListView.builder(
                      controller: _horizontalScrollController,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: 20,
                      ),
                      itemCount: isManager
                          ? boardLists.length + 1
                          : boardLists.length,
                      itemBuilder: (context, index) {
                        if (index < boardLists.length) {
                          final listTitle = boardLists[index];
                          final listTasks = boardTasks
                              .where((t) => t['listName'] == listTitle)
                              .toList();
                          final isLocked = lockedLists.contains(listTitle);

                          return _buildKanbanColumn(
                            listTitle,
                            listTasks,
                            isManager,
                            isLocked,
                          );
                        } else {
                          return _buildAddListCard();
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKanbanColumn(
    String title,
    List<Map<String, dynamic>> tasks,
    bool isManager,
    bool isLocked,
  ) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final bool isHovered = _hoveredListName == title;

    return DragTarget<Map<String, dynamic>>(
      onWillAcceptWithDetails: (details) {
        if (isLocked) return false;
        return true;
      },
      onAcceptWithDetails: (details) {
        _stopAutoScroll();
        setState(() {
          _hoveredListName = null;
        });
        final task = details.data;
        if (task['listName'] != title) {
          HapticFeedback.mediumImpact();
          AppDataController.instance.moveTaskToList(task['id'], title);
        }
      },
      onMove: (details) {
        _handleDragAutoScroll(details.offset);
        if (!isLocked && _hoveredListName != title) {
          setState(() {
            _hoveredListName = title;
          });
        }
      },
      onLeave: (data) {
        if (_hoveredListName == title) {
          setState(() {
            _hoveredListName = null;
          });
        }
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 280,
          margin: EdgeInsets.only(
            right: 16,
            bottom: bottomPadding > 0 ? bottomPadding : 12,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                color: isHovered
                    ? AppColors.primary.withOpacity(0.08)
                    : AppColors.surfaceMuted.withOpacity(0.5),
                borderRadius: AppRadius.roundedLg,
                border: Border.all(
                  color: isHovered
                      ? AppColors.primary
                      : AppColors.borderLight.withOpacity(0.4),
                  width: isHovered ? 1.8 : 1.0,
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              title,
                              style: AppTextStyles.cardTitle.copyWith(
                                fontSize: 15,
                                color: isHovered
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                              ),
                            ),
                            if (isLocked) ...[
                              const SizedBox(width: 6),
                              Icon(
                                Icons.lock_rounded,
                                size: 14,
                                color: AppColors.textMuted,
                              ),
                            ],
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isHovered
                                    ? AppColors.primary.withOpacity(0.15)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${tasks.length}',
                                style: AppTextStyles.cardSubtitle.copyWith(
                                  fontWeight: isHovered
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isHovered
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            InkWell(
                              onTap: () => _showListOptionsModal(
                                context,
                                title,
                                isManager,
                                isLocked,
                              ),
                              borderRadius: BorderRadius.circular(4),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.more_horiz_rounded,
                                  color: AppColors.textMuted,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (tasks.isEmpty && !isHovered)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: Text(
                            'Belum ada task',
                            style: AppTextStyles.cardSubtitle.copyWith(
                              fontSize: 12,
                            ),
                          ),
                        ),
                      )
                    else
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) =>
                              _buildTaskCard(tasks[index], isLocked),
                        ),
                      ),

                    // Placeholder saat task melayang masuk ke list ini
                    if (isHovered && _draggingTaskId != null)
                      Container(
                        height: 48,
                        margin: const EdgeInsets.only(bottom: 10, top: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: AppRadius.roundedMd,
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.5),
                            width: 1.5,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.arrow_downward_rounded,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Lepas untuk memindahkan ke sini',
                                style: AppTextStyles.cardSubtitle.copyWith(
                                  fontSize: 12,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 8),

                    // Tombol Tambah Task (Merespon Status Kunci)
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          if (isLocked) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Kolom ini dikunci. Anda tidak bisa menambahkan task baru.',
                                ),
                              ),
                            );
                          } else {
                            _showAddTaskModal(title);
                          }
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.roundedMd,
                          ),
                        ),
                        child: Text(
                          '+ Tambah Task',
                          style: AppTextStyles.cardSubtitle.copyWith(
                            color: isLocked
                                ? AppColors.textMuted.withOpacity(0.5)
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddListCard() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 16),
        child: InkWell(
          onTap: _showAddListModal,
          borderRadius: AppRadius.roundedLg,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.roundedLg,
              border: Border.all(color: AppColors.borderLight, width: 1.5),
              boxShadow: const [AppShadows.card],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Tambah List Baru',
                  style: AppTextStyles.cardTitle.copyWith(
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task, bool isLocked) {
    final bool isCompleted = task['isDone'] ?? false;
    final int? coverColorVal = task['coverColor'];
    final String coverSize = task['coverSize'] ?? 'header';
    final Color? coverColor = coverColorVal != null
        ? Color(coverColorVal)
        : null;

    final List<dynamic> members = task['members'] ?? [];

    Widget cardContent({bool isDragging = false, bool isFeedback = false}) {
      return Container(
        width: 256,
        margin: EdgeInsets.only(bottom: isFeedback ? 0 : 10),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: coverSize == 'full' && coverColor != null
              ? coverColor
              : AppColors.surface,
          borderRadius: AppRadius.roundedMd,
          border: Border.all(
            color: isFeedback ? AppColors.primary : AppColors.borderLight,
            width: isFeedback ? 1.5 : 1.0,
          ),
          boxShadow: isFeedback
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ]
              : const [AppShadows.card],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // MENAMPILKAN COVER JIKA ADA
            if (coverColor != null && coverSize == 'header')
              Container(height: 32, width: double.infinity, color: coverColor),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          AppDataController.instance.toggleTaskCompletion(
                            task['id'],
                          );
                        },
                        child: Container(
                          width: 18,
                          height: 18,
                          margin: const EdgeInsets.only(top: 2, right: 10),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? AppColors.primary
                                : (coverSize == 'full'
                                      ? Colors.white30
                                      : Colors.transparent),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isCompleted
                                  ? AppColors.primary
                                  : (coverSize == 'full'
                                        ? Colors.white
                                        : AppColors.border),
                              width: 1.5,
                            ),
                          ),
                          child: isCompleted
                              ? const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          task['title'] ?? '',
                          style: AppTextStyles.cardTitle.copyWith(
                            fontSize: 14,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: coverSize == 'full' && coverColor != null
                                ? Colors.white
                                : (isCompleted
                                      ? AppColors.textMuted
                                      : AppColors.textPrimary),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.more_horiz_rounded,
                        size: 16,
                        color: coverSize == 'full'
                            ? Colors.white70
                            : AppColors.textMuted,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 14,
                        color: coverSize == 'full'
                            ? Colors.white70
                            : AppColors.textMuted,
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.attach_file_rounded,
                        size: 14,
                        color: coverSize == 'full'
                            ? Colors.white70
                            : AppColors.textMuted,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Avatar Anggota Dinamis
                      Row(
                        children: members.take(3).map((m) {
                          return _buildMiniAvatar(Color(m['color']));
                        }).toList(),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 12,
                            color: coverSize == 'full'
                                ? Colors.white70
                                : AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            task['date'] ?? 'No Date',
                            style: AppTextStyles.cardSubtitle.copyWith(
                              fontSize: 11,
                              color: coverSize == 'full'
                                  ? Colors.white
                                  : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final taskCard = GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TaskDetailScreen(taskId: task['id']),
          ),
        );
      },
      child: cardContent(),
    );

    if (isLocked) {
      return taskCard;
    }

    return LongPressDraggable<Map<String, dynamic>>(
      data: task,
      dragAnchorStrategy: childDragAnchorStrategy,
      hapticFeedbackOnStart: true,
      onDragStarted: () {
        HapticFeedback.selectionClick();
        setState(() {
          _draggingTaskId = task['id'];
        });
      },
      onDragEnd: (details) {
        _stopAutoScroll();
        setState(() {
          _draggingTaskId = null;
          _hoveredListName = null;
        });
      },
      onDraggableCanceled: (velocity, offset) {
        _stopAutoScroll();
        setState(() {
          _draggingTaskId = null;
          _hoveredListName = null;
        });
      },
      // Widget saat di tempat asal ketika sedang di-drag (placeholder transparan & mengecil)
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            borderRadius: AppRadius.roundedMd,
            border: Border.all(
              color: AppColors.primary.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: cardContent(),
        ),
      ),
      // Widget feedback yang melayang mengikuti kursor/jari (mengecil 0.93 & melayang dengan shadow)
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 0.93,
          child: Opacity(opacity: 0.96, child: cardContent(isFeedback: true)),
        ),
      ),
      child: taskCard,
    );
  }

  Widget _buildMiniAvatar(Color color) {
    return Container(
      width: 20,
      height: 20,
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.2),
      ),
      child: Icon(Icons.person_rounded, size: 12, color: color),
    );
  }
}
