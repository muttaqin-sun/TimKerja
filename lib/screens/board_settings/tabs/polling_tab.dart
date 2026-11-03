import 'package:flutter/material.dart';

import '../../../../data/app_data.dart';
import '../../../../theme/app_theme.dart';
import '../create_poll_screen.dart';

class PollingTab extends StatelessWidget {
  final String boardId;
  final bool isManager;

  const PollingTab({super.key, required this.boardId, required this.isManager});

  // ===========================================================================
  // MODAL 1: TAMPILAN CEPAT (Sesuai Gambar 2)
  // ===========================================================================
  void _showQuickPollModal(
    BuildContext context,
    Map<String, dynamic> rawPoll,
    int totalVotes,
    List normalizedOptions,
  ) {
    final String title = rawPoll['question']?.toString() ?? 'Tanpa Judul';
    final String creator = rawPoll['creator']?.toString() ?? 'Anggota';
    final String date = rawPoll['date']?.toString() ?? 'Hari ini';
    final bool isActive = rawPoll['isClosed'] != true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle Bar atas
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // Header (Ikon, Judul, Close Button)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE6F7F5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bar_chart_rounded,
                        color: AppColors.primary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTextStyles.screenTitle.copyWith(
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Dibuat oleh $creator • $date, 14.30',
                            style: AppTextStyles.cardSubtitle.copyWith(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black54),
                      onPressed: () => Navigator.pop(ctx),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Baris Status Aktif & Total Suara
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFFE6F7F5)
                            : AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isActive ? 'Aktif' : 'Selesai',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isActive
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.people_alt_outlined,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$totalVotes suara',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Pertanyaan Box
                Text(
                  'Pertanyaan',
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Kapan waktu yang paling cocok untuk acara Makrab HIMSI tahun ini?', // Fallback/Dummy teks sesuai gambar
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1E293B),
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Pilihan Opsi
                Text(
                  'Pilihan Opsi',
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 12),

                ...normalizedOptions.map((opt) {
                  final String optTitle = opt['title'];
                  final int voteCount = (opt['votes'] as List).length;
                  final double percent = totalVotes == 0
                      ? 0.0
                      : (voteCount / totalVotes);
                  return _buildOptionRow(
                    optTitle,
                    voteCount,
                    percent,
                    withNumber: false,
                  );
                }),

                const SizedBox(height: 24),

                // Tombol Lihat Detail
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx); // Tutup modal 1
                      _showDetailPollModal(
                        context,
                        rawPoll,
                        totalVotes,
                        normalizedOptions,
                      ); // Buka modal 2
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE6F7F5),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Lihat Detail >',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
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

  // ===========================================================================
  // MODAL 2: TAMPILAN DETAIL (Sesuai Gambar 1)
  // ===========================================================================
  void _showDetailPollModal(
    BuildContext context,
    Map<String, dynamic> rawPoll,
    int totalVotes,
    List normalizedOptions,
  ) {
    final String title = rawPoll['question']?.toString() ?? 'Tanpa Judul';
    final String creator = rawPoll['creator']?.toString() ?? 'Anggota';
    final String date = rawPoll['date']?.toString() ?? 'Hari ini';
    final bool isActive = rawPoll['isClosed'] != true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle Bar atas
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // Header Sama dengan modal 1
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE6F7F5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bar_chart_rounded,
                        color: AppColors.primary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTextStyles.screenTitle.copyWith(
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Dibuat oleh $creator • $date, 14.30',
                            style: AppTextStyles.cardSubtitle.copyWith(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black54),
                      onPressed: () => Navigator.pop(ctx),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Card Info Detail (Durasi & Total Peserta)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Durasi Polling',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const Text(
                                  '24 jam',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F7F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.people_alt,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Peserta',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Text(
                                  '$totalVotes orang',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Pertanyaan Box
                Text(
                  'Pertanyaan',
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Kapan waktu yang paling cocok untuk acara Makrab HIMSI tahun ini?',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1E293B),
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Pilihan Opsi Dengan Angka
                Text(
                  'Pilihan Opsi',
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 12),

                ...normalizedOptions.asMap().entries.map((entry) {
                  final int index = entry.key;
                  final opt = entry.value;
                  final String optTitle = opt['title'];
                  final int voteCount = (opt['votes'] as List).length;
                  final double percent = totalVotes == 0
                      ? 0.0
                      : (voteCount / totalVotes);

                  return _buildOptionRow(
                    optTitle,
                    voteCount,
                    percent,
                    withNumber: true,
                    index: index + 1,
                  );
                }),

                const SizedBox(height: 24),

                // Banner Selesai (Hanya contoh fallback/dummy visual)
                if (!isActive || true) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F7F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Polling telah berakhir',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              'Berakhir pada 13 Okt 2025, 14.30',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Tombol Tutup
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFE6F7F5),
                      side: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Tutup',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
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

  // WIDGET BANTUAN: Baris Opsi Polling Responsif
  Widget _buildOptionRow(
    String title,
    int votes,
    double percent, {
    required bool withNumber,
    int? index,
  }) {
    final String percentStr = (percent * 100)
        .toStringAsFixed(1)
        .replaceAll('.0', '');

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          if (withNumber && index != null) ...[
            Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: Color(0xFFE6F7F5),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$index',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 4,
            child: Text(
              title,
              style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 8,
                backgroundColor: const Color(0xFFF1F5F9),
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: Text(
              '$percentStr% ($votes suara)',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // FUNGSI NORMALISASI DATA & ENTRY POINT
  // ===========================================================================
  void _processAndShowPoll(BuildContext context, Map<String, dynamic> rawPoll) {
    final List normalizedOptions = [];
    final rawOptions = rawPoll['options'];

    if (rawOptions is List && rawOptions.isNotEmpty) {
      for (var item in rawOptions) {
        if (item is Map) {
          normalizedOptions.add({
            'title': (item['title'] ?? item['text'] ?? 'Opsi').toString(),
            'votes': (item['votes'] is List) ? List.from(item['votes']) : [],
          });
        } else if (item != null) {
          normalizedOptions.add({'title': item.toString(), 'votes': []});
        }
      }
    } else {
      // Fallback Dummy Data
      normalizedOptions.addAll([
        {
          'title': '10–11 Januari 2026',
          'votes': ['1', '2'],
        },
        {
          'title': '17–18 Januari 2026',
          'votes': ['1', '2', '3'],
        },
        {
          'title': '24–25 Januari 2026',
          'votes': ['1'],
        },
      ]);
    }

    int totalVotes = 0;
    for (var opt in normalizedOptions) {
      totalVotes += (opt['votes'] as List).length;
    }

    // Panggil modal 1 (Quick view) sebagai awal mula klik board
    _showQuickPollModal(context, rawPoll, totalVotes, normalizedOptions);
  }

  // ===========================================================================
  // MAIN BUILD METHOD (Tampilan Tab Utama tetap dipertahankan)
  // ===========================================================================
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppDataController.instance,
      builder: (context, _) {
        Map<String, dynamic> board = {};
        try {
          final found = AppDataController.instance.boards.firstWhere(
            (b) => b['id'] == boardId,
            orElse: () => <String, dynamic>{'title': 'Board'},
          );
          if (found is Map) {
            board = Map<String, dynamic>.from(found);
          }
        } catch (_) {}

        final String boardTitle = board['title']?.toString() ?? 'Board';
        final List dynamicPolls = (board['polls'] is List)
            ? board['polls']
            : [];

        return ListView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daftar Polling',
                  style: AppTextStyles.screenTitle.copyWith(fontSize: 18),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreatePollScreen(
                          boardId: boardId,
                          boardTitle: boardTitle,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text(
                    'Buat Polling',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    backgroundColor: Colors.white,
                    side: const BorderSide(
                      color: AppColors.primary,
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 1. POLLING DINAMIS
            ...dynamicPolls.map((poll) {
              if (poll is! Map) return const SizedBox.shrink();
              final pollMap = Map<String, dynamic>.from(poll);

              int totalRespondents = 0;
              if (pollMap['options'] is List) {
                for (var opt in (pollMap['options'] as List)) {
                  if (opt is Map && opt['votes'] is List) {
                    totalRespondents += (opt['votes'] as List).length;
                  }
                }
              }

              return _buildPollCard(
                title: pollMap['question']?.toString() ?? 'Tanpa Judul',
                creator: pollMap['creator']?.toString() ?? 'Anggota',
                date: pollMap['date']?.toString() ?? 'Hari ini',
                respondents: totalRespondents,
                isActive: pollMap['isClosed'] != true,
                onTap: () => _processAndShowPoll(context, pollMap),
              );
            }),

            // 2. DUMMY POLLING (Fallback Statis)
            _buildPollCard(
              title: 'Jadwal Makrab',
              creator: 'Ilham Muttaqin',
              date: '12 Okt 2025',
              respondents: 6,
              isActive: true,
              onTap: () => _processAndShowPoll(context, {
                'question': 'Jadwal Makrab',
                'creator': 'Ilham Muttaqin',
                'date': '12 Okt 2025',
                'options': [
                  {
                    'title': '10–11 Januari 2026',
                    'votes': ['1', '2'],
                  },
                  {
                    'title': '17–18 Januari 2026',
                    'votes': ['1', '2', '3'],
                  },
                  {
                    'title': '24–25 Januari 2026',
                    'votes': ['1'],
                  },
                ],
              }),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPollCard({
    required String title,
    required String creator,
    required String date,
    required int respondents,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight, width: 1.2),
          boxShadow: const [AppShadows.card],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE6F7F5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bar_chart_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Dibuat oleh $creator',
                          style: AppTextStyles.cardSubtitle.copyWith(
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 14,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              date,
                              style: AppTextStyles.cardSubtitle.copyWith(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFFF0FAF8)
                          : AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primary
                                : AppColors.textMuted,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isActive ? 'Aktif' : 'Selesai',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isActive
                                ? AppColors.primary
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey,
                    size: 20,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.people_outline_rounded,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$respondents responden',
                    style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
