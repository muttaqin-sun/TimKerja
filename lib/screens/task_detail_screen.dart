import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../theme/app_theme.dart';

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

  final FocusNode _descFocusNode = FocusNode();
  bool _isEditingDesc = false;
  String _tempDescValue = '';

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

  @override
  void initState() {
    super.initState();
    final task = AppDataController.instance.tasks.firstWhere(
      (t) => t['id'] == widget.taskId,
      orElse: () => {},
    );
    _tempDescValue = task['desc'] ?? '';
    _descCtrl = TextEditingController(text: _tempDescValue);

    _descFocusNode.addListener(() {
      setState(() {
        _isEditingDesc = _descFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _subtaskCtrl.dispose();
    _commentCtrl.dispose();
    _descFocusNode.dispose();
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

  void _addComment() {
    if (_commentCtrl.text.trim().isNotEmpty) {
      AppDataController.instance.addComment(
        widget.taskId,
        _commentCtrl.text.trim(),
      );
      _commentCtrl.clear();
      FocusScope.of(context).unfocus();
    }
  }

  void _showAttachLinkDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'CANCEL',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tautan ditambahkan')),
                );
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
      builder: (context) {
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
                    Navigator.pop(context);
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
                    Navigator.pop(context);
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
                  onTap: () {
                    Navigator.pop(context);
                    _showAttachLinkDialog();
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
                    Navigator.pop(context);
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
        return StatefulBuilder(
          builder: (context, setModalState) {
            final int? currentCoverVal = task['coverColor'];
            final String currentSize = task['coverSize'] ?? 'header';
            final Color? currentColor = currentCoverVal != null
                ? Color(currentCoverVal)
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
                                        AppDataController.instance.setTaskCover(
                                          widget.taskId,
                                          currentColor,
                                          size: 'header',
                                        );
                                        setModalState(
                                          () => task['coverSize'] = 'header',
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
                                              currentSize == 'header' &&
                                                  currentColor != null
                                              ? AppColors.primary
                                              : AppColors.border,
                                          width:
                                              currentSize == 'header' &&
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
                                        AppDataController.instance.setTaskCover(
                                          widget.taskId,
                                          currentColor,
                                          size: 'full',
                                        );
                                        setModalState(
                                          () => task['coverSize'] = 'full',
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
                                              currentSize == 'full' &&
                                                  currentColor != null
                                              ? AppColors.primary
                                              : AppColors.border,
                                          width:
                                              currentSize == 'full' &&
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
                                final isSelected =
                                    currentColor?.value == color.value;
                                return GestureDetector(
                                  onTap: () {
                                    AppDataController.instance.setTaskCover(
                                      widget.taskId,
                                      color,
                                      size: currentSize,
                                    );
                                    setModalState(
                                      () => task['coverColor'] = color.value,
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
                                              width: 2,
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

  Widget _buildAttachmentCard(String title, IconData icon) {
    return GestureDetector(
      onTap: _showAttachmentBottomSheet,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.roundedMd,
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Icon(icon, color: AppColors.textMuted, size: 32),
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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppDataController.instance,
      builder: (context, _) {
        final task = AppDataController.instance.tasks.firstWhere(
          (t) => t['id'] == widget.taskId,
          orElse: () => {'title': 'Tugas tidak ditemukan'},
        );

        if (task['id'] == null)
          return const Scaffold(
            body: Center(child: Text('Tugas tidak ditemukan')),
          );

        final subtasks = (task['subtasks'] as List?) ?? [];
        final comments = (task['comments'] as List?) ?? [];
        final attachments = (task['attachments'] as List?) ?? [];
        final members = (task['members'] as List?) ?? [];
        final currentUser = AppDataController.instance.currentUserProfile;

        final completedSubtasks = subtasks
            .where((s) => s['isDone'] == true)
            .length;
        final board = AppDataController.instance.boards.firstWhere(
          (b) => b['id'] == task['boardId'],
          orElse: () => {'title': 'Unknown'},
        );
        final String currentStatus = task['status'] ?? 'To Do';

        final int? coverColorVal = task['coverColor'];
        final Color? coverColor = coverColorVal != null
            ? Color(coverColorVal)
            : null;

        // Membaca tanggal dari global state
        final String startDateDisplay =
            (task['startDate'] != null && task['startDate'] != 'Tanggal')
            ? "${task['startDate']} ${task['startTime'] ?? ''}"
            : "";
        final String dueDateDisplay =
            (task['dueDate'] != null && task['dueDate'] != 'Tanggal')
            ? "${task['dueDate']} ${task['dueTime'] ?? ''}"
            : "";

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
                        onPressed: () => _showCoverSettingsModal(task),
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
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.border,
                                  width: 2,
                                ),
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
                      const SizedBox(height: 24),

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

                      if (_isEditingDesc) ...[
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
                          onTap: () => _showStartDateDialog(task),
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
                                  style: AppTextStyles.cardSubtitle,
                                )
                              : null,
                          onTap: () => _showDueDateDialog(task),
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
                            onPressed: _showAttachmentBottomSheet,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
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
                                  att['name'],
                                  att['icon'],
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
                          onChanged: (_) => AppDataController.instance
                              .toggleSubtask(widget.taskId, index),
                        );
                      }),
                      Row(
                        children: [
                          InkWell(
                            onTap: _addSubtask,
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
                              decoration: InputDecoration(
                                hintText: 'Tambah subtask...',
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
                                'Anggota',
                                style: AppTextStyles.sectionTitle,
                              ),
                            ],
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textMuted,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (members.isEmpty)
                        Text(
                          'Belum ada anggota tim pada tugas ini.',
                          style: AppTextStyles.cardSubtitle,
                        )
                      else
                        Row(
                          children: [
                            ...members.take(3).map((m) {
                              return _buildMemberAvatar(
                                Color(m['color']),
                                initials: _getInitials(m['name']),
                              );
                            }),
                            if (members.length > 3)
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.surfaceMuted,
                                ),
                                child: Center(
                                  child: Text(
                                    '+${members.length - 3}',
                                    style: AppTextStyles.cardSubtitle.copyWith(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
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
