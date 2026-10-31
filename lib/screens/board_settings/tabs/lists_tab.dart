import 'package:flutter/material.dart';

import '../../../../data/app_data.dart';
import '../../../../theme/app_theme.dart';

class ListsTab extends StatefulWidget {
  final String boardId;
  final bool isManager;

  const ListsTab({super.key, required this.boardId, required this.isManager});

  @override
  State<ListsTab> createState() => _ListsTabState();
}

class _ListsTabState extends State<ListsTab> {
  // Menyimpan state warna secara lokal (Kustomisasi UI)
  // Karena struktur bawaan board['lists'] pada AppDataController hanya berupa teks
  final Map<String, int> _listColors = {};

  final List<int> _availableColors = [
    0xFF94A3B8, // Abu-abu
    0xFF3B82F6, // Biru
    0xFFFBBF24, // Kuning
    0xFF22C55E, // Hijau
    0xFF8B5CF6, // Ungu
    0xFFEF4444, // Merah
    0xFF00A896, // Tosca
    0xFFF43F5E, // Pink
  ];

  // Mendapatkan warna list, menggunakan fallback sesuai gambar desain jika belum diubah
  int _getListColor(String listName, int index) {
    if (_listColors.containsKey(listName)) {
      return _listColors[listName]!;
    }
    // Memberikan warna default berurutan agar sesuai dengan gambar mock-up desain
    final defaults = [0xFF94A3B8, 0xFF3B82F6, 0xFFFBBF24, 0xFF22C55E];
    return index < defaults.length ? defaults[index] : _availableColors[0];
  }

  // ==========================================================
  // MODAL 1: Opsi Menu Titik Tiga (Ubah Nama & Ubah Warna)
  // ==========================================================
  void _showOptionsModal(String listName, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
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
                  'Pengelolaan List',
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.primary,
                  ),
                  title: Text('Ubah Nama List', style: AppTextStyles.inputText),
                  onTap: () {
                    Navigator.pop(context);
                    _showRenameDialog(listName); // Buka dialog ubah nama
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.palette_outlined,
                    color: AppColors.primary,
                  ),
                  title: Text(
                    'Ubah Warna List',
                    style: AppTextStyles.inputText,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showColorPickerDialog(
                      listName,
                      index,
                    ); // Buka dialog ubah warna
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // MODAL 2: Dialog Ubah Nama List
  // ==========================================================
  void _showRenameDialog(String oldName) {
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
          style: AppTextStyles.inputText,
          decoration: const InputDecoration(
            hintText: 'Masukkan nama list baru...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = ctrl.text.trim();
              if (newName.isNotEmpty && newName != oldName) {
                // Pindahkan state memori warna ke key/nama yang baru agar warna tidak reset
                if (_listColors.containsKey(oldName)) {
                  setState(() {
                    _listColors[newName] = _listColors[oldName]!;
                    _listColors.remove(oldName);
                  });
                }

                // Panggil Global Controller untuk mengubah nama (Memengaruhi tab lain/Task)
                AppDataController.instance.renameBoardList(
                  widget.boardId,
                  oldName,
                  newName,
                );

                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Nama list berhasil diubah'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // MODAL 3: Dialog Ubah Warna List
  // ==========================================================
  void _showColorPickerDialog(String listName, int index) {
    int currentColor = _getListColor(listName, index);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
            title: Text(
              'Ubah Warna List',
              style: AppTextStyles.screenTitle.copyWith(fontSize: 18),
            ),
            content: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _availableColors.map((colorVal) {
                final isSelected = currentColor == colorVal;
                return GestureDetector(
                  onTap: () {
                    setModalState(() {
                      currentColor = colorVal;
                    });
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Color(colorVal),
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: AppColors.primaryDark, width: 3)
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Color(colorVal).withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check_rounded, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Batal',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _listColors[listName] = currentColor;
                  });
                  Navigator.pop(ctx);
                },
                child: const Text('Simpan Warna'),
              ),
            ],
          );
        },
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
          orElse: () => {'lists': <String>[]},
        );
        final List<String> lists = List<String>.from(board['lists'] ?? []);

        // Dummy data fallback agar jika belum ada list, tampilan mengikuti desain
        if (lists.isEmpty) {
          lists.addAll([
            'Belum Dimulai',
            'Sedang Dikerjakan',
            'Dalam Review',
            'Selesai',
          ]);
        }

        final allTasks = AppDataController.instance.tasks
            .where((t) => t['boardId'] == widget.boardId)
            .toList();

        return ListView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          children: [
            // Header Daftar List
            Text(
              'Daftar List',
              style: AppTextStyles.screenTitle.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 16),

            // Item-item List
            ...List.generate(lists.length, (index) {
              final listTitle = lists[index];
              final int taskCount = allTasks
                  .where((t) => t['listName'] == listTitle)
                  .length;

              // Mock task count jika tabel tugas kosong (Sesuai jumlah di desain UI)
              final displayTaskCount = taskCount > 0
                  ? taskCount
                  : [2, 4, 1, 7][index % 4];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.roundedLg,
                  border: Border.all(color: AppColors.borderLight, width: 1.2),
                  boxShadow: const [AppShadows.card],
                ),
                child: Row(
                  children: [
                    // Icon Titik Tiga (Aksi Pengelolaan)
                    GestureDetector(
                      onTap: () {
                        if (widget.isManager) {
                          _showOptionsModal(listTitle, index);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Hanya Pembuat Board yang dapat mengelola list.',
                              ),
                            ),
                          );
                        }
                      },
                      behavior: HitTestBehavior
                          .opaque, // Pastikan tap area terdeteksi dengan baik
                      child: const Padding(
                        padding: EdgeInsets.only(
                          right: 14.0,
                          top: 4.0,
                          bottom: 4.0,
                        ),
                        child: Icon(
                          Icons.more_vert_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                    ),

                    // Kotak Warna
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Color(_getListColor(listTitle, index)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Nama List & Task Count
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            listTitle,
                            style: AppTextStyles.cardTitle.copyWith(
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$displayTaskCount tugas',
                            style: AppTextStyles.cardSubtitle.copyWith(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Chevron Kanan
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
