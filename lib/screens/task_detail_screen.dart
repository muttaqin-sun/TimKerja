import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../theme/app_theme.dart';

import 'dart:io';
import 'dart:async';

import '../widgets/upload_progress_card.dart';
import '../widgets/attachment_viewer.dart';
import '../widgets/mention_suggestion_box.dart';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;
  const TaskDetailScreen({super.key, required this.taskId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TextEditingController _descCtrl;
  final TextEditingController _subtaskCtrl = TextEditingController();
  final TextEditingController _commentCtrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final FocusNode _descFocusNode = FocusNode();
  bool _isEditingDesc = false;
  String _tempDescValue = '';

  // Ganti _isUploadingAttachment dengan 4 variabel berikut:
  UploadStatus _uploadStatus = UploadStatus.idle;
  double _uploadProgress = 0.0;
  String _uploadingFileName = '';
  String? _uploadErrorMsg;

  final List<Color> _coverColors = const [
    Color(0xFF61BD4F),
    Color(0xFFF2D600),
    Color(0xFFFF9F1A),
    Color(0xFFEB5A46),
    Color(0xFFC377E0),
    Color(0xFF0079BF),
    Color(0xFF00C2E0),
    Color(0xFF51E898),
    Color(0xFFFF78CB),
    Color(0xFF344563),
  ];

  String? _commentMentionQuery;
  @override
  void initState() {
    super.initState();
    final task = AppDataController.instance.tasks.firstWhere(
      (t) => t['id'] == widget.taskId,
      orElse: () => <String, dynamic>{},
    );
    _tempDescValue = task['desc'] ?? '';
    _descCtrl = TextEditingController(text: _tempDescValue);

    _descFocusNode.addListener(() {
      setState(() {
        _isEditingDesc = _descFocusNode.hasFocus;
      });
    });
    _commentCtrl.addListener(() {
      final q = MentionHelper.getActiveMentionQuery(_commentCtrl);
      if (q != _commentMentionQuery && mounted) {
        setState(() => _commentMentionQuery = q);
      }
    });
    // Tarik data lampiran terbaru dari Supabase saat halaman detail dibuka
    AppDataController.instance.loadTaskAttachments(widget.taskId);
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _subtaskCtrl.dispose();
    _commentCtrl.dispose();
    _descFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _saveDescription() {
    AppDataController.instance.updateTaskDesc(widget.taskId, _descCtrl.text);
    setState(() {
      _tempDescValue = _descCtrl.text;
      _isEditingDesc = false;
    });
    _descFocusNode.unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Deskripsi disimpan'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _cancelDescriptionEdit() {
    setState(() {
      _descCtrl.text = _tempDescValue;
      _isEditingDesc = false;
    });
    _descFocusNode.unfocus();
  }

  void _addSubtask() {
    if (_subtaskCtrl.text.trim().isNotEmpty) {
      AppDataController.instance.addSubtask(
        widget.taskId,
        _subtaskCtrl.text.trim(),
      );
      _subtaskCtrl.clear();
    }
  }

  void _addComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;

    final task = AppDataController.instance.tasks.firstWhere(
      (t) => t['id'] == widget.taskId,
      orElse: () => <String, dynamic>{},
    );
    final String boardId = task['boardId']?.toString() ?? '';
    final String taskTitle = task['title']?.toString() ?? 'Tugas';

    AppDataController.instance.addComment(widget.taskId, text);
    _commentCtrl.clear();
    setState(() => _commentMentionQuery = null);
    FocusScope.of(context).unfocus();

    if (boardId.isNotEmpty) {
      await AppDataController.instance.processMentionsAndNotify(
        boardId: boardId,
        contentText: text,
        contextLabel: 'Task "$taskTitle"',
        referenceId: widget.taskId,
      );
    }

    // Auto-scroll ke komentar paling bawah
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Future<void> _pickPhotoFromCamera() async {
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (photo == null) return;

    setState(() {
      _uploadStatus = UploadStatus.uploading;
      _uploadProgress = 0.1;
      _uploadingFileName = photo.name;
      _uploadErrorMsg = null;
    });

    final timer = Timer.periodic(const Duration(milliseconds: 200), (t) {
      if (!mounted || _uploadStatus != UploadStatus.uploading) {
        t.cancel();
        return;
      }
      setState(() {
        if (_uploadProgress < 0.88) {
          _uploadProgress += 0.08;
        }
      });
    });

    try {
      await AppDataController.instance.uploadTaskFileAttachment(
        widget.taskId,
        file: File(photo.path),
        fileName: photo.name,
        type: 'image',
      );
      timer.cancel();
      if (mounted) {
        setState(() {
          _uploadProgress = 1.0;
          _uploadStatus = UploadStatus.success;
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && _uploadStatus == UploadStatus.success) {
            setState(() => _uploadStatus = UploadStatus.idle);
          }
        });
      }
    } catch (e) {
      timer.cancel();
      if (mounted) {
        setState(() {
          _uploadStatus = UploadStatus.error;
          _uploadErrorMsg = 'Gagal mengunggah foto';
        });
      }
    }
  }

  Future<void> _pickDocumentFile() async {
    final result = await FilePicker.pickFiles();
    if (result.isEmpty || result.single.path == null) return;

    final picked = result.single;
    final String ext = (picked.extension ?? '').toLowerCase();
    final bool isImg = ['jpg', 'jpeg', 'png', 'webp'].contains(ext);

    setState(() {
      _uploadStatus = UploadStatus.uploading;
      _uploadProgress = 0.1;
      _uploadingFileName = picked.name;
      _uploadErrorMsg = null;
    });

    // Simulasi kenaikan bertahap 10% -> 88% selama proses upload berlangsung
    final timer = Timer.periodic(const Duration(milliseconds: 200), (t) {
      if (!mounted || _uploadStatus != UploadStatus.uploading) {
        t.cancel();
        return;
      }
      setState(() {
        if (_uploadProgress < 0.88) {
          _uploadProgress += 0.08;
        }
      });
    });

    try {
      await AppDataController.instance.uploadTaskFileAttachment(
        widget.taskId,
        file: File(picked.path!),
        fileName: picked.name,
        type: isImg ? 'image' : 'file',
      );
      timer.cancel();
      if (mounted) {
        setState(() {
          _uploadProgress = 1.0;
          _uploadStatus = UploadStatus.success;
        });
        // Sembunyikan kartu setelah 2 detik menampilkan animasi centang sukses
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && _uploadStatus == UploadStatus.success) {
            setState(() => _uploadStatus = UploadStatus.idle);
          }
        });
      }
    } catch (e) {
      timer.cancel();
      if (mounted) {
        setState(() {
          _uploadStatus = UploadStatus.error;
          _uploadErrorMsg = 'Gagal mengunggah berkas';
        });
      }
    }
  }

  void _showAttachLinkDialog({String initialUrl = ''}) {
    final urlCtrl = TextEditingController(text: initialUrl);
    final nameCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
          title: Text(
            'Attach a link',
            style: AppTextStyles.cardTitle.copyWith(fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                color: Colors.grey.shade200,
                child: TextField(
                  controller: urlCtrl,
                  style: AppTextStyles.inputText.copyWith(fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Paste any link here...',
                    labelStyle: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                color: Colors.grey.shade200,
                child: TextField(
                  controller: nameCtrl,
                  style: AppTextStyles.inputText.copyWith(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Link name (optional)',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'CANCEL',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                final url = urlCtrl.text.trim();
                if (url.isEmpty) return;
                final title = nameCtrl.text.trim().isNotEmpty
                    ? nameCtrl.text.trim()
                    : url;
                Navigator.pop(dialogContext);

                try {
                  await AppDataController.instance.addTaskLinkAttachment(
                    widget.taskId,
                    name: title,
                    url: url,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tautan ditambahkan'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal menyimpan tautan: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAttachmentBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Icon(
                    Icons.camera_alt_outlined,
                    color: AppColors.textPrimary,
                    size: 24,
                  ),
                  title: Text(
                    'Take photo',
                    style: AppTextStyles.cardTitle.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickPhotoFromCamera();
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.attach_file_rounded,
                    color: AppColors.textPrimary,
                    size: 24,
                  ),
                  title: Text(
                    'File',
                    style: AppTextStyles.cardTitle.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickDocumentFile();
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.content_paste_rounded,
                    color: AppColors.textPrimary,
                    size: 24,
                  ),
                  title: Text(
                    'Clipboard',
                    style: AppTextStyles.cardTitle.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    final clipData = await Clipboard.getData(
                      Clipboard.kTextPlain,
                    );
                    _showAttachLinkDialog(initialUrl: clipData?.text ?? '');
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.open_in_new_rounded,
                    color: AppColors.textPrimary,
                    size: 24,
                  ),
                  title: Text(
                    'Attach a link',
                    style: AppTextStyles.cardTitle.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showAttachLinkDialog();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLockedSnackBar() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Tugas terkunci karena telah melewati batas waktu. Hubungi Manager untuk memperpanjang tenggat waktu.',
        ),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _showRevisionDialog() {
    final noteCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Minta Revisi Tugas',
          style: AppTextStyles.cardTitle.copyWith(fontSize: 17),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tugas akan dikembalikan ke status In Progress. Berikan catatan perbaikan untuk anggota:',
              style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteCtrl,
              maxLines: 3,
              style: AppTextStyles.inputText.copyWith(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Contoh: Tolong lengkapi lampiran bukti pengujian...',
                hintStyle: AppTextStyles.cardSubtitle.copyWith(fontSize: 12),
                filled: true,
                fillColor: AppColors.surfaceMuted,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Batal',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await AppDataController.instance.reviewTaskDecision(
                taskId: widget.taskId,
                isApproved: false,
                reviewNote: noteCtrl.text,
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Permintaan revisi dikirim ke anggota'),
                    backgroundColor: AppColors.warning,
                  ),
                );
              }
            },
            child: const Text(
              'Kirim Revisi',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFauxDropdown({
    required String text,
    required List<String> items,
    required Function(String) onSelected,
  }) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      color: AppColors.surface,
      itemBuilder: (context) {
        return items
            .map(
              (item) => PopupMenuItem(
                value: item,
                child: Text(
                  item,
                  style: AppTextStyles.inputText.copyWith(fontSize: 14),
                ),
              ),
            )
            .toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade400, width: 1.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.inputText.copyWith(fontSize: 14),
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showStartDateDialog(Map<String, dynamic> task) {
    String localDateText = task['startDate'] ?? "Tanggal";
    String localTimeText = task['startTime'] ?? "Waktu";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              title: Text(
                'Start date',
                style: AppTextStyles.cardTitle.copyWith(fontSize: 18),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: _buildFauxDropdown(
                          text: localDateText,
                          items: [
                            'Hari ini',
                            'Besok',
                            'Minggu Depan',
                            'Pilih tanggal...',
                          ],
                          onSelected: (val) async {
                            if (val == 'Pilih tanggal...') {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) {
                                setModalState(
                                  () => localDateText =
                                      "${date.day}/${date.month}/${date.year}",
                                );
                              }
                            } else {
                              setModalState(() => localDateText = val);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 4,
                        child: _buildFauxDropdown(
                          text: localTimeText,
                          items: [
                            'Pagi',
                            'Siang',
                            'Sore',
                            'Malam',
                            'Pilih waktu...',
                          ],
                          onSelected: (val) async {
                            if (val == 'Pilih waktu...') {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (time != null) {
                                setModalState(
                                  () => localTimeText =
                                      "${time.hour.toString().padLeft(2, '0')}.${time.minute.toString().padLeft(2, '0')}",
                                );
                              }
                            } else {
                              setModalState(() => localTimeText = val);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setModalState(() {
                          localDateText = "Tanggal";
                          localTimeText = "Waktu";
                        }),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Update data ke memori global
                    AppDataController.instance.setTaskStartDate(
                      widget.taskId,
                      localDateText,
                      localTimeText,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'DONE',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDueDateDialog(Map<String, dynamic> task) {
    String localDateText = task['dueDate'] ?? "Tanggal";
    String localTimeText = task['dueTime'] ?? "Waktu";
    String localReminder = task['reminder'] ?? "1 hari sebelumnya";
    bool localAddMe = task['addMeToCard'] ?? false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              title: Text(
                'Due date',
                style: AppTextStyles.cardTitle.copyWith(fontSize: 18),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: _buildFauxDropdown(
                          text: localDateText,
                          items: [
                            'Hari ini',
                            'Besok',
                            'Minggu Depan',
                            'Pilih tanggal...',
                          ],
                          onSelected: (val) async {
                            if (val == 'Pilih tanggal...') {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (date != null)
                                setModalState(
                                  () => localDateText =
                                      "${date.day}/${date.month}/${date.year}",
                                );
                            } else {
                              setModalState(() => localDateText = val);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 4,
                        child: _buildFauxDropdown(
                          text: localTimeText,
                          items: [
                            'Pagi',
                            'Siang',
                            'Sore',
                            'Malam',
                            'Pilih waktu...',
                          ],
                          onSelected: (val) async {
                            if (val == 'Pilih waktu...') {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (time != null)
                                setModalState(
                                  () => localTimeText =
                                      "${time.hour.toString().padLeft(2, '0')}.${time.minute.toString().padLeft(2, '0')}",
                                );
                            } else {
                              setModalState(() => localTimeText = val);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setModalState(() {
                          localDateText = "Tanggal";
                          localTimeText = "Waktu";
                        }),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Set reminder',
                    style: AppTextStyles.cardSubtitle.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFauxDropdown(
                          text: localReminder,
                          items: [
                            'Pada saat tenggat waktu',
                            '15 menit sebelumnya',
                            '1 jam sebelumnya',
                            '1 hari sebelumnya',
                          ],
                          onSelected: (val) =>
                              setModalState(() => localReminder = val),
                        ),
                      ),
                      const SizedBox(width: 28),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Reminders are only sent to members and watchers of the card.',
                    style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Add me to the card',
                        style: AppTextStyles.inputText.copyWith(fontSize: 14),
                      ),
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: localAddMe,
                          activeColor: Colors.blue,
                          onChanged: (val) =>
                              setModalState(() => localAddMe = val ?? false),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Update data ke memori global
                    AppDataController.instance.setTaskDueDate(
                      widget.taskId,
                      localDateText,
                      localTimeText,
                      localReminder,
                      localAddMe,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'DONE',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCoverSettingsModal(Map<String, dynamic> task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        int? modalColorVal = task['coverColor'] != null
            ? int.tryParse(task['coverColor'].toString())
            : null;
        String modalSize = task['coverSize'] ?? 'header';

        return StatefulBuilder(
          builder: (context, setModalState) {
            final Color? currentColor = modalColorVal != null
                ? Color(modalColorVal!)
                : null;

            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.85,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Text(
                            'Cover settings',
                            style: AppTextStyles.screenTitle.copyWith(
                              fontSize: 18,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: AppColors.error,
                            ),
                            onPressed: () {
                              setModalState(() {
                                modalColorVal = null;
                              });
                              AppDataController.instance.setTaskCover(
                                widget.taskId,
                                null,
                              );
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Sizes', style: AppTextStyles.sectionTitle),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      if (currentColor != null) {
                                        setModalState(() {
                                          modalSize = 'header';
                                        });
                                        AppDataController.instance.setTaskCover(
                                          widget.taskId,
                                          currentColor,
                                          size: 'header',
                                        );
                                      }
                                    },
                                    child: Container(
                                      height: 70,
                                      decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius: AppRadius.roundedMd,
                                        border: Border.all(
                                          color:
                                              modalSize == 'header' &&
                                                  currentColor != null
                                              ? AppColors.primary
                                              : AppColors.border,
                                          width:
                                              modalSize == 'header' &&
                                                  currentColor != null
                                              ? 2
                                              : 1,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color:
                                                    currentColor ??
                                                    Colors.grey.shade300,
                                                borderRadius:
                                                    const BorderRadius.vertical(
                                                      top: Radius.circular(6),
                                                    ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                6.0,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    height: 4,
                                                    width: double.infinity,
                                                    color: Colors.grey.shade300,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Container(
                                                    height: 4,
                                                    width: 40,
                                                    color: Colors.grey.shade300,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      if (currentColor != null) {
                                        setModalState(() {
                                          modalSize = 'full';
                                        });
                                        AppDataController.instance.setTaskCover(
                                          widget.taskId,
                                          currentColor,
                                          size: 'full',
                                        );
                                      }
                                    },
                                    child: Container(
                                      height: 70,
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color:
                                            currentColor ??
                                            Colors.grey.shade300,
                                        borderRadius: AppRadius.roundedMd,
                                        border: Border.all(
                                          color:
                                              modalSize == 'full' &&
                                                  currentColor != null
                                              ? AppColors.primary
                                              : AppColors.border,
                                          width:
                                              modalSize == 'full' &&
                                                  currentColor != null
                                              ? 2
                                              : 1,
                                        ),
                                      ),
                                      alignment: Alignment.bottomLeft,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            height: 4,
                                            width: double.infinity,
                                            color: Colors.white70,
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            height: 4,
                                            width: 40,
                                            color: Colors.white70,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            Text('Colors', style: AppTextStyles.sectionTitle),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: _coverColors.map((color) {
                                final isSelected = modalColorVal == color.value;
                                return GestureDetector(
                                  onTap: () {
                                    setModalState(() {
                                      modalColorVal = color.value;
                                    });
                                    AppDataController.instance.setTaskCover(
                                      widget.taskId,
                                      color,
                                      size: modalSize,
                                    );
                                  },
                                  child: Container(
                                    width:
                                        (MediaQuery.of(context).size.width -
                                            80) /
                                        5,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(6),
                                      border: isSelected
                                          ? Border.all(
                                              color: AppColors.primary,
                                              width: 2.5,
                                            )
                                          : null,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'Done') return AppColors.success;
    if (status == 'In Progress') return AppColors.warning;
    return AppColors.textMuted;
  }

  Widget _buildAttachmentCard(Map<String, dynamic> att) {
    final String type = (att['type'] ?? 'link').toString();
    final String url = (att['url'] ?? '').toString();
    final String title = (att['name'] ?? 'Lampiran').toString();

    IconData iconData = Icons.link_rounded;
    if (type == 'image') iconData = Icons.image_outlined;
    if (type == 'file') iconData = Icons.insert_drive_file_outlined;

    return GestureDetector(
      onTap: () {
        if (url.isEmpty) return;

        if (type == 'image') {
          AttachmentViewer.showImage(context, url: url, fileName: title);
        } else if (type == 'file') {
          AttachmentViewer.showFile(context, url: url, fileName: title);
        } else {
          Clipboard.setData(ClipboardData(text: url));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tautan "$title" disalin ke clipboard')),
          );
        }
      },
      onLongPress: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Hapus Lampiran?'),
            content: Text('Hapus "$title" dari tugas ini?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  AppDataController.instance.removeTaskAttachment(
                    widget.taskId,
                    att['id'].toString(),
                  );
                },
                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.roundedMd,
              border: Border.all(color: AppColors.borderLight),
            ),
            child: (type == 'image' && url.isNotEmpty)
                ? Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Icon(iconData, color: AppColors.primary, size: 32),
                  )
                : Icon(iconData, color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 80,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.cardSubtitle.copyWith(fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    List<String> parts = name.split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  Widget _buildMemberAvatar(Color color, {required String initials}) {
    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.15),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showAssignMembersModal(
    Map<String, dynamic> task,
    List<dynamic> boardMembers,
  ) {
    final List currentTaskMembers = (task['members'] as List?) ?? [];
    final Set<String> selectedIds = currentTaskMembers
        .map((m) => (m is Map ? m['userId']?.toString() : '') ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tugaskan Anggota',
                      style: AppTextStyles.screenTitle.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pilih anggota board yang bertanggung jawab pada tugas ini',
                      style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.45,
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: boardMembers.length,
                        itemBuilder: (context, index) {
                          final m = boardMembers[index] as Map;
                          final String uid = m['userId']?.toString() ?? '';
                          final String name =
                              m['name']?.toString() ?? 'Anggota';
                          final String role = m['role']?.toString() ?? 'Member';
                          final int colorVal = m['color'] is int
                              ? m['color'] as int
                              : 0xFF00A896;
                          final bool isChecked = selectedIds.contains(uid);

                          return CheckboxListTile(
                            value: isChecked,
                            activeColor: AppColors.primary,
                            contentPadding: EdgeInsets.zero,
                            secondary: CircleAvatar(
                              radius: 18,
                              backgroundColor: Color(colorVal)
                                  .withOpacity(0.15),
                              child: Text(
                                _getInitials(name),
                                style: TextStyle(
                                  color: Color(colorVal),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            title: Text(
                              name,
                              style: AppTextStyles.cardTitle.copyWith(
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              role,
                              style: AppTextStyles.cardSubtitle.copyWith(
                                fontSize: 11,
                              ),
                            ),
                            onChanged: (val) {
                              setModalState(() {
                                if (val == true) {
                                  selectedIds.add(uid);
                                } else {
                                  selectedIds.remove(uid);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final chosenMembers = boardMembers
                              .where(
                                (m) =>
                                    m is Map &&
                                    selectedIds.contains(
                                      m['userId']?.toString(),
                                    ),
                              )
                              .map((m) => Map<String, dynamic>.from(m as Map))
                              .toList();

                          Navigator.pop(ctx);
                          await AppDataController.instance.updateTaskAssignees(
                            taskId: widget.taskId,
                            selectedMembers: chosenMembers,
                          );

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Penugasan anggota berhasil diperbarui',
                                ),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Simpan Penugasan',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppDataController.instance,
      builder: (context, _) {
        final task = AppDataController.instance.tasks.firstWhere(
          (t) => t['id'] == widget.taskId,
          orElse: () => <String, dynamic>{'title': 'Tugas tidak ditemukan'},
        );

        if (task['id'] == null) {
          return const Scaffold(
            body: Center(child: Text('Tugas tidak ditemukan')),
          );
        }

        final subtasks = (task['subtasks'] as List?) ?? [];
        final comments = (task['comments'] as List?) ?? [];
        final attachments = (task['attachments'] as List?) ?? [];
        final currentUser = AppDataController.instance.currentUserProfile;

        final completedSubtasks = subtasks
            .where((s) => s['isDone'] == true)
            .length;
        final board = AppDataController.instance.boards.firstWhere(
          (b) => b['id'] == task['boardId'],
          orElse: () => <String, dynamic>{'title': 'Unknown'},
        );
        final boardMembers = (board['members'] as List?) ?? [];
        final members = (task['members'] as List?)?.isNotEmpty == true
            ? (task['members'] as List)
            : boardMembers;
        final String currentStatus = task['status'] ?? 'To Do';

        final int? coverColorVal = task['coverColor'] != null
            ? int.tryParse(task['coverColor'].toString())
            : null;
        final Color? coverColor = coverColorVal != null
            ? Color(coverColorVal)
            : null;

        final String startDateDisplay =
            (task['startDate'] != null && task['startDate'] != 'Tanggal')
            ? "${task['startDate']} ${task['startTime'] ?? ''}"
            : "";
        final String dueDateDisplay =
            (task['dueDate'] != null && task['dueDate'] != 'Tanggal')
            ? "${task['dueDate']} ${task['dueTime'] ?? ''}"
            : "";

        // Cek peran user, status review (Tahap 3), dan status overdue (Tahap 4)
        final String myUserId = currentUser['id']?.toString() ?? '';
        final currentMemberMap = boardMembers.firstWhere(
          (m) => m is Map && m['userId']?.toString() == myUserId,
          orElse: () => <String, dynamic>{},
        );
        final String myRole = (currentMemberMap['role']?.toString() ?? '')
            .toLowerCase();
        final bool isManager =
            myRole == 'manager' || myRole == 'owner' || myRole == 'admin';

        final String reviewStatus = task['reviewStatus']?.toString() ?? 'none';
        final String? reviewNote = task['reviewNote']?.toString();
        final bool showReviewSection =
            reviewStatus != 'none' || (isManager && task['isDone'] == true);

        final bool isOverdue = AppDataController.instance.isTaskOverdue(task);
        final bool isLockedForMember = isOverdue && !isManager;

        return Scaffold(
          backgroundColor: AppColors.background,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            backgroundColor: coverColor ?? AppColors.background,
            elevation: 0,
            iconTheme: IconThemeData(
              color: coverColor != null ? Colors.white : AppColors.textPrimary,
            ),
            title: Text(
              'Detail Task',
              style: AppTextStyles.screenTitle.copyWith(
                fontSize: 18,
                color: coverColor != null
                    ? Colors.white
                    : AppColors.textPrimary,
              ),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              if (coverColor != null && task['coverSize'] == 'full')
                Container(
                  height: 60,
                  width: double.infinity,
                  color: coverColor,
                ),

              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: EdgeInsets.only(
                    left: AppSpacing.screenPadding.left,
                    right: AppSpacing.screenPadding.right,
                    top: 16,
                    bottom: 100,
                  ),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OutlinedButton.icon(
                        onPressed: isLockedForMember
                            ? null
                            : () => _showCoverSettingsModal(task),
                        icon: const Icon(Icons.video_label_rounded, size: 18),
                        label: const Text('Cover'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          backgroundColor: AppColors.surface,
                          side: BorderSide(color: AppColors.borderLight),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: AppRadius.roundedLg,
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (isLockedForMember) {
                                  _showLockedSnackBar();
                                  return;
                                }
                                AppDataController.instance.toggleTaskCompletion(
                                  widget.taskId,
                                );
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: task['isDone'] == true
                                      ? AppColors.success
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: task['isDone'] == true
                                        ? AppColors.success
                                        : AppColors.border,
                                    width: 2,
                                  ),
                                ),
                                child: task['isDone'] == true
                                    ? const Icon(
                                        Icons.check_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task['title'] ?? '',
                                    style: AppTextStyles.cardTitle.copyWith(
                                      fontSize: 16,
                                      decoration: (task['isDone'] == true)
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.folder_rounded,
                                        size: 14,
                                        color: AppColors.textMuted,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          '${board['title']} • ${task['listName'] ?? 'No List'}',
                                          style: AppTextStyles.cardSubtitle
                                              .copyWith(fontSize: 12),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(currentStatus)
                                              .withOpacity(0.15),
                                          borderRadius: AppRadius.roundedXs,
                                        ),
                                        child: Text(
                                          currentStatus,
                                          style: AppTextStyles.cardSubtitle
                                              .copyWith(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: _getStatusColor(
                                                  currentStatus,
                                                ),
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Banner Penguncian Akses Jika Overdue (Tahap 4)
                      if (isOverdue) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: AppRadius.roundedLg,
                            border: Border.all(
                              color: const Color(0xFFFCA5A5),
                              width: 1.3,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.lock_clock_rounded,
                                color: AppColors.error,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isLockedForMember
                                          ? 'Akses Dikunci (Melewati Tenggat)'
                                          : 'Tugas Melewati Tenggat Waktu',
                                      style: AppTextStyles.cardTitle.copyWith(
                                        fontSize: 13,
                                        color: const Color(0xFF991B1B),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      isLockedForMember
                                          ? 'Batas waktu pengerjaan telah berakhir. Hubungi Manager untuk memperpanjang Due Date.'
                                          : 'Tugas ini telah melewati tenggat. Sebagai Manager, Anda dapat memperpanjang Due Date di bawah untuk membuka kunci bagi anggota.',
                                      style: AppTextStyles.cardSubtitle
                                          .copyWith(
                                            fontSize: 11,
                                            color: const Color(0xFFB91C1C),
                                            height: 1.35,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Panel Validasi & Revisi Tugas oleh Manager (Tahap 3)
                      if (showReviewSection) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: reviewStatus == 'approved'
                                ? const Color(0xFFECFDF5)
                                : reviewStatus == 'revision'
                                ? const Color(0xFFFEF2F2)
                                : const Color(0xFFFFFBEB),
                            borderRadius: AppRadius.roundedLg,
                            border: Border.all(
                              color: reviewStatus == 'approved'
                                  ? const Color(0xFFA7F3D0)
                                  : reviewStatus == 'revision'
                                  ? const Color(0xFFFECACA)
                                  : const Color(0xFFFDE68A),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    reviewStatus == 'approved'
                                        ? Icons.verified_rounded
                                        : reviewStatus == 'revision'
                                        ? Icons.assignment_return_rounded
                                        : Icons.hourglass_top_rounded,
                                    size: 20,
                                    color: reviewStatus == 'approved'
                                        ? AppColors.success
                                        : reviewStatus == 'revision'
                                        ? AppColors.error
                                        : AppColors.warning,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      reviewStatus == 'approved'
                                          ? 'Tugas Tervalidasi (Valid)'
                                          : reviewStatus == 'revision'
                                          ? 'Perlu Revisi dari Manager'
                                          : 'Menunggu Validasi Manager',
                                      style: AppTextStyles.cardTitle.copyWith(
                                        fontSize: 13,
                                        color: reviewStatus == 'approved'
                                            ? const Color(0xFF065F46)
                                            : reviewStatus == 'revision'
                                            ? const Color(0xFF991B1B)
                                            : const Color(0xFF92400E),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (reviewNote != null &&
                                  reviewNote.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Catatan Manager: "$reviewNote"',
                                    style: AppTextStyles.cardSubtitle.copyWith(
                                      fontSize: 12,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                              if (isManager &&
                                  (reviewStatus == 'pending_review' ||
                                      (task['isDone'] == true &&
                                          reviewStatus != 'approved'))) ...[
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: _showRevisionDialog,
                                        icon: const Icon(
                                          Icons.edit_note_rounded,
                                          size: 18,
                                        ),
                                        label: const Text(
                                          'Revisi',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.error,
                                          side: const BorderSide(
                                            color: AppColors.error,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          await AppDataController.instance
                                              .reviewTaskDecision(
                                                taskId: widget.taskId,
                                                isApproved: true,
                                              );
                                          if (mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Tugas disetujui sebagai Valid',
                                                    ),
                                                    backgroundColor:
                                                        AppColors.success,
                                                  ),
                                                );
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.check_circle_outline_rounded,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                        label: const Text(
                                          'Setujui (Valid)',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.success,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (!isManager && reviewStatus == 'revision') ...[
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: isLockedForMember
                                        ? _showLockedSnackBar
                                        : () async {
                                            await AppDataController.instance
                                                .submitTaskForReview(
                                                  widget.taskId,
                                                );
                                            if (mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Revisi dikirim ulang untuk validasi Manager',
                                                      ),
                                                      backgroundColor:
                                                          AppColors.primary,
                                                    ),
                                                  );
                                            }
                                          },
                                    icon: const Icon(
                                      Icons.send_rounded,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      'Kirim Ulang Hasil Revisi',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      Row(
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 20,
                            color: AppColors.textPrimary,
                          ),
                          const SizedBox(width: 8),
                          Text('Deskripsi', style: AppTextStyles.sectionTitle),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _descCtrl,
                        focusNode: _descFocusNode,
                        readOnly: isLockedForMember,
                        maxLines: 4,
                        style: AppTextStyles.inputText.copyWith(
                          fontSize: 13,
                          height: 1.5,
                          color: AppColors.textSecondary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Tulis deskripsi...',
                          border: OutlineInputBorder(
                            borderRadius: AppRadius.roundedMd,
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: AppColors.surface,
                        ),
                      ),

                      if (_isEditingDesc && !isLockedForMember) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: _saveDescription,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.green,
                                    width: 1.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.green,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            InkWell(
                              onTap: _cancelDescriptionEdit,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.red,
                                    width: 1.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 20),

                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.schedule_rounded,
                            color: AppColors.textPrimary,
                            size: 20,
                          ),
                          title: Text(
                            'Start date',
                            style: AppTextStyles.sectionTitle.copyWith(
                              fontSize: 14,
                            ),
                          ),
                          trailing: startDateDisplay.isNotEmpty
                              ? Text(
                                  startDateDisplay,
                                  style: AppTextStyles.cardSubtitle,
                                )
                              : null,
                          onTap: () {
                            if (isLockedForMember) {
                              _showLockedSnackBar();
                              return;
                            }
                            _showStartDateDialog(task);
                          },
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.access_time_rounded,
                            color: AppColors.textPrimary,
                            size: 20,
                          ),
                          title: Text(
                            'Due date',
                            style: AppTextStyles.sectionTitle.copyWith(
                              fontSize: 14,
                            ),
                          ),
                          trailing: dueDateDisplay.isNotEmpty
                              ? Text(
                                  dueDateDisplay,
                                  style: AppTextStyles.cardSubtitle.copyWith(
                                    color: isOverdue ? AppColors.error : null,
                                    fontWeight: isOverdue
                                        ? FontWeight.bold
                                        : null,
                                  ),
                                )
                              : null,
                          onTap: () {
                            if (isLockedForMember) {
                              _showLockedSnackBar();
                              return;
                            }
                            _showDueDateDialog(task);
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.attach_file_rounded,
                                size: 20,
                                color: AppColors.textPrimary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Lampiran',
                                style: AppTextStyles.sectionTitle,
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_rounded, size: 20),
                            color: AppColors.primary,
                            onPressed: () {
                              if (isLockedForMember) {
                                _showLockedSnackBar();
                                return;
                              }
                              _showAttachmentBottomSheet();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      UploadProgressCard(
                        status: _uploadStatus,
                        progress: _uploadProgress,
                        fileName: _uploadingFileName,
                        errorMessage: _uploadErrorMsg,
                      ),
                      if (attachments.isEmpty)
                        Text(
                          'Belum ada lampiran.',
                          style: AppTextStyles.cardSubtitle,
                        )
                      else
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: attachments.map((att) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: _buildAttachmentCard(
                                  Map<String, dynamic>.from(att as Map),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.checklist_rounded,
                                size: 20,
                                color: AppColors.textPrimary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Subtask',
                                style: AppTextStyles.sectionTitle,
                              ),
                            ],
                          ),
                          Text(
                            '$completedSubtasks/${subtasks.length} selesai',
                            style: AppTextStyles.cardSubtitle,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(subtasks.length, (index) {
                        final item = subtasks[index];
                        final isDone = item['isDone'] as bool;
                        return CheckboxListTile(
                          value: isDone,
                          activeColor: AppColors.primary,
                          checkColor: Colors.white,
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          visualDensity: VisualDensity.compact,
                          secondary: IconButton(
                            icon: const Icon(Icons.close_rounded, size: 16),
                            color: AppColors.textMuted,
                            onPressed: isLockedForMember
                                ? _showLockedSnackBar
                                : () {
                                    AppDataController.instance.deleteSubtask(
                                      widget.taskId,
                                      index,
                                    );
                                  },
                          ),
                          title: Text(
                            item['title'],
                            style: AppTextStyles.cardTitle.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              decoration: isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: isDone
                                  ? AppColors.textMuted
                                  : AppColors.textPrimary,
                            ),
                          ),
                          onChanged: isLockedForMember
                              ? null
                              : (_) => AppDataController.instance.toggleSubtask(
                                  widget.taskId,
                                  index,
                                ),
                        );
                      }),
                      Row(
                        children: [
                          InkWell(
                            onTap: isLockedForMember
                                ? _showLockedSnackBar
                                : _addSubtask,
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.add_rounded,
                                size: 20,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _subtaskCtrl,
                              enabled: !isLockedForMember,
                              decoration: InputDecoration(
                                hintText: isLockedForMember
                                    ? 'Subtask terkunci (melewati deadline)'
                                    : 'Tambah subtask...',
                                hintStyle: AppTextStyles.cardSubtitle,
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              style: AppTextStyles.inputText.copyWith(
                                fontSize: 14,
                              ),
                              onSubmitted: (_) => _addSubtask(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline_rounded,
                                size: 20,
                                color: AppColors.textPrimary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Anggota Ditugaskan',
                                style: AppTextStyles.sectionTitle,
                              ),
                            ],
                          ),
                          if (isManager)
                            TextButton.icon(
                              onPressed: () =>
                                  _showAssignMembersModal(task, boardMembers),
                              icon: const Icon(
                                Icons.person_add_alt_1_rounded,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              label: const Text(
                                'Atur',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if ((task['members'] as List? ?? []).isEmpty)
                        Text(
                          isManager
                              ? 'Belum ada anggota ditugaskan. Ketuk "Atur" untuk memilih anggota.'
                              : 'Belum ada anggota ditugaskan pada tugas ini.',
                          style: AppTextStyles.cardSubtitle,
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: (task['members'] as List).map((m) {
                            final name = m['name']?.toString() ?? 'Anggota';
                            final colorVal = m['color'] is int
                                ? m['color'] as int
                                : 0xFF00A896;
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Color(colorVal).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Color(colorVal).withOpacity(0.4),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 10,
                                    backgroundColor: Color(colorVal),
                                    child: Text(
                                      _getInitials(name),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(colorVal),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 24),

                      Text('Komentar', style: AppTextStyles.sectionTitle),
                      const SizedBox(height: 12),
                      if (comments.isNotEmpty) ...[
                        ...comments.map((comment) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: AppRadius.roundedLg,
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      comment['author'] ?? 'Unknown',
                                      style: AppTextStyles.cardTitle.copyWith(
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      comment['time'] ?? '',
                                      style: AppTextStyles.cardSubtitle
                                          .copyWith(fontSize: 10),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  comment['text'] ?? '',
                                  style: AppTextStyles.inputText.copyWith(
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                      const SizedBox(height: 12),

                      if (_commentMentionQuery != null)
                        MentionSuggestionBox(
                          members: boardMembers,
                          query: _commentMentionQuery!,
                          currentUserId: currentUser['id']?.toString() ?? '',
                          onSelectMember: (name) {
                            MentionHelper.insertMention(_commentCtrl, name);
                            setState(() => _commentMentionQuery = null);
                          },
                        ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: AppRadius.roundedLg,
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: Color(
                                currentUser['avatarColor'],
                              ),
                              child: Text(
                                currentUser['initials'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _commentCtrl,
                                style: AppTextStyles.inputText.copyWith(
                                  fontSize: 13,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Tulis komentar...',
                                  hintStyle: AppTextStyles.cardSubtitle,
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                onSubmitted: (_) => _addComment(),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.send_rounded, size: 18),
                              color: AppColors.primary,
                              onPressed: _addComment,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
