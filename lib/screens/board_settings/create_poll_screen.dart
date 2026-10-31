import 'package:flutter/material.dart';

import '../../../data/app_data.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/top_decor_blob.dart';

class CreatePollScreen extends StatefulWidget {
  final String boardId;
  final String boardTitle;

  const CreatePollScreen({
    super.key,
    required this.boardId,
    required this.boardTitle,
  });

  @override
  State<CreatePollScreen> createState() => _CreatePollScreenState();
}

class _CreatePollScreenState extends State<CreatePollScreen> {
  final TextEditingController _titleController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  String? _selectedDate;
  String? _selectedTime;
  bool _showResultsBeforeVote = true;
  bool _enableNotification = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    for (var ctrl in _optionControllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    if (_optionControllers.length < 5) {
      setState(() => _optionControllers.add(TextEditingController()));
    }
  }

  void _removeOption(int index) {
    if (_optionControllers.length > 2) {
      setState(() {
        _optionControllers[index].dispose();
        _optionControllers.removeAt(index);
      });
    }
  }

  Future<void> _pickDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() => _selectedDate = "${date.day} Okt ${date.year}");
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        _selectedTime =
            "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  void _handleCreatePoll() {
    final question = _titleController.text.trim();
    final validOptions = _optionControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (question.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul polling tidak boleh kosong.')),
      );
      return;
    }
    if (validOptions.length < 2) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Masukkan minimal 2 opsi.')));
      return;
    }

    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      AppDataController.instance.addPoll(
        widget.boardId,
        question,
        validOptions,
      );
      setState(() => _isLoading = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Polling berhasil dibuat!'),
          backgroundColor: AppColors.primary,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const TopDecorBlob(size: 160),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Column(
                        children: [
                          Text(
                            'Buat Polling',
                            style: AppTextStyles.screenTitle.copyWith(
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.boardTitle,
                            style: AppTextStyles.cardSubtitle.copyWith(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. JUDUL POLLING
                        _buildCardContainer(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySurface,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.bar_chart_rounded,
                                  color: AppColors.primary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Judul Polling',
                                      style: AppTextStyles.cardTitle.copyWith(
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: _titleController,
                                      style: AppTextStyles.inputText.copyWith(
                                        fontSize: 13,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Contoh: Jadwal presentasi minggu depan...',
                                        hintStyle: TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 13,
                                        ),
                                        filled: true,
                                        fillColor: AppColors.surfaceMuted,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 12,
                                            ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 2. OPSI PILIHAN
                        _buildCardContainer(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.list_alt_rounded,
                                        size: 20,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Opsi Pilihan',
                                        style: AppTextStyles.cardTitle.copyWith(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Maks. 5 opsi',
                                    style: AppTextStyles.cardSubtitle.copyWith(
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ...List.generate(_optionControllers.length, (
                                index,
                              ) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: AppColors.primarySurface,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${index + 1}',
                                            style: const TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextField(
                                          controller: _optionControllers[index],
                                          style: AppTextStyles.inputText
                                              .copyWith(fontSize: 13),
                                          decoration: InputDecoration(
                                            hintText: 'Opsi ${index + 1}',
                                            hintStyle: TextStyle(
                                              color: AppColors.textMuted,
                                              fontSize: 13,
                                            ),
                                            filled: true,
                                            fillColor: AppColors.surfaceMuted,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 14,
                                                  vertical: 0,
                                                ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide.none,
                                            ),
                                            suffixIcon:
                                                _optionControllers.length > 2
                                                ? IconButton(
                                                    icon: Icon(
                                                      Icons.close_rounded,
                                                      size: 18,
                                                      color:
                                                          AppColors.textMuted,
                                                    ),
                                                    onPressed: () =>
                                                        _removeOption(index),
                                                  )
                                                : null,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              if (_optionControllers.length < 5)
                                GestureDetector(
                                  onTap: _addOption,
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColors.primary,
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(
                                          Icons.add_rounded,
                                          size: 18,
                                          color: AppColors.primary,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'Tambah Opsi',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 3. BATAS WAKTU
                        _buildCardContainer(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.event_rounded,
                                    size: 20,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Batas Waktu',
                                          style: AppTextStyles.cardTitle
                                              .copyWith(fontSize: 14),
                                        ),
                                        Text(
                                          'Pilih tanggal dan waktu berakhir polling',
                                          style: AppTextStyles.cardSubtitle
                                              .copyWith(fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildPickerBox(
                                      Icons.calendar_today_rounded,
                                      _selectedDate ?? 'Pilih Tanggal',
                                      _pickDate,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildPickerBox(
                                      Icons.access_time_rounded,
                                      _selectedTime ?? 'Pilih Waktu',
                                      _pickTime,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 4. PENGATURAN
                        _buildCardContainer(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.settings_outlined,
                                    size: 20,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Pengaturan',
                                        style: AppTextStyles.cardTitle.copyWith(
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        'Atur siapa yang dapat memberikan suara',
                                        style: AppTextStyles.cardSubtitle
                                            .copyWith(fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildSettingItem(
                                Icons.group_outlined,
                                'Siapa yang bisa voting?',
                                'Semua anggota board',
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Semua anggota',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      size: 18,
                                      color: AppColors.textMuted,
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 24, thickness: 1),
                              _buildSettingItem(
                                Icons.visibility_outlined,
                                'Tampilkan hasil sebelum memilih?',
                                'Anggota bisa melihat hasil polling',
                                Switch.adaptive(
                                  value: _showResultsBeforeVote,
                                  activeColor: AppColors.primary,
                                  onChanged: (val) => setState(
                                    () => _showResultsBeforeVote = val,
                                  ),
                                ),
                              ),
                              const Divider(height: 24, thickness: 1),
                              _buildSettingItem(
                                Icons.notifications_none_rounded,
                                'Notifikasi',
                                'Kirim notifikasi saat selesai',
                                Switch.adaptive(
                                  value: _enableNotification,
                                  activeColor: AppColors.primary,
                                  onChanged: (val) =>
                                      setState(() => _enableNotification = val),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tombol Submit Bawah
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: AppColors.background,
              child: SafeArea(
                top: false, // Hanya aktifkan padding aman untuk bagian bawah
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _handleCreatePoll,
                    icon: _isLoading
                        ? const SizedBox.shrink()
                        : const Icon(
                            Icons.near_me_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                    label: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Buat Polling',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.roundedLg,
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [AppShadows.card],
      ),
      child: child,
    );
  }

  Widget _buildPickerBox(IconData icon, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.textMuted),
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                color: text.contains('Pilih')
                    ? AppColors.textMuted
                    : AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    IconData icon,
    String title,
    String subtitle,
    Widget trailing,
  ) {
    return Row(
      children: [
        Icon(icon, size: 24, color: AppColors.primary),
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
        trailing,
      ],
    );
  }
}
