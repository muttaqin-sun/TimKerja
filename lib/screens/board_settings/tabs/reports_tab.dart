import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';

class ReportsTab extends StatefulWidget {
  final String boardId;
  final bool isManager;

  const ReportsTab({super.key, required this.boardId, required this.isManager});

  @override
  State<ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends State<ReportsTab> {
  // --- Data Dummy ---
  final _memberStats = [
    {
      'name': 'Ilham Muttaqin',
      'initial': 'IP',
      'assigned': 5,
      'completed': 4,
      'percent': 80,
    },
    {
      'name': 'Sari',
      'initial': 'ST',
      'assigned': 4,
      'completed': 2,
      'percent': 50,
    },
    {
      'name': 'Budi',
      'initial': 'BD',
      'assigned': 3,
      'completed': 1,
      'percent': 33,
    },
    {'name': '-', 'initial': '-', 'assigned': 0, 'completed': 0, 'percent': 0},
  ];

  final _recentActivities = [
    {
      'name': 'Sari',
      'action': 'menyelesaikan tugas',
      'task': 'Laporan Bab 1',
      'time': '2 jam lalu',
      'type': 'complete',
    },
    {
      'name': 'Budi',
      'action': 'memindahkan tugas',
      'task': 'Desain UI → Dalam Proses',
      'time': '4 jam lalu',
      'type': 'move',
    },
    {
      'name': 'Ilham',
      'action': 'menambahkan tugas',
      'task': 'Riset Referensi',
      'time': '6 jam lalu',
      'type': 'add',
    },
  ];

  void _showDummyToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        // 1. HEADER RINGKASAN PROYEK
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ringkasan Proyek',
              style: AppTextStyles.screenTitle.copyWith(fontSize: 16),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 12,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Minggu ini',
                    style: AppTextStyles.cardSubtitle.copyWith(
                      fontSize: 11,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 2. KARTU METRIK TUGAS (4 Kolom)
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: Icons.assignment_outlined,
                count: '12',
                label: 'Total Tugas',
                color: AppColors.primary,
                bgColor: AppColors.primarySurface,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.check_rounded,
                count: '7',
                label: 'Selesai',
                color: AppColors.primary,
                bgColor: AppColors.primarySurface,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.access_time_rounded,
                count: '3',
                label: 'Dalam Proses',
                color: const Color(0xFF3B82F6),
                bgColor: const Color(0xFFEFF6FF),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.more_horiz_rounded,
                count: '2',
                label: 'Belum Dimulai',
                color: AppColors.textMuted,
                bgColor: AppColors.surfaceMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 3. PROGRESS BOARD & DONUT CHART
        Text(
          'Progress Board',
          style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
        ),
        const SizedBox(height: 12),
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
              // Progress Linear Kiri
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '58%',
                      style: AppTextStyles.screenTitle.copyWith(
                        fontSize: 28,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tugas selesai',
                      style: AppTextStyles.cardSubtitle.copyWith(fontSize: 11),
                    ),
                    const SizedBox(height: 12),
                    _buildLinearProgressBar(0.58, AppColors.primary, height: 8),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Grafik Donut Kanan
              Expanded(
                flex: 5,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(64, 64),
                            painter: _DonutChartPainter(
                              completed: 7,
                              inProgress: 3,
                              notStarted: 2,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '7/12',
                                style: AppTextStyles.cardTitle.copyWith(
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                'Tugas',
                                style: AppTextStyles.cardSubtitle.copyWith(
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLegendItem(AppColors.primary, 'Selesai', '7'),
                          const SizedBox(height: 6),
                          _buildLegendItem(
                            const Color(0xFF3B82F6),
                            'Dalam Proses',
                            '3',
                          ),
                          const SizedBox(height: 6),
                          _buildLegendItem(
                            const Color(0xFFCBD5E1),
                            'Belum Dimulai',
                            '2',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 4. STATISTIK ANGGOTA
        _buildSectionHeader(
          'Statistik Anggota',
          Icons.people_outline_rounded,
          onSeeAll: () => _showDummyToast('Lihat semua anggota'),
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
            children: [
              // Header Tabel
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted.withOpacity(0.5),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        'Nama',
                        style: AppTextStyles.cardTitle.copyWith(
                          fontSize: 10,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: Text(
                          'Ditugaskan',
                          style: AppTextStyles.cardTitle.copyWith(
                            fontSize: 10,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Text(
                          'Selesai',
                          style: AppTextStyles.cardTitle.copyWith(
                            fontSize: 10,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Persentase',
                        style: AppTextStyles.cardTitle.copyWith(
                          fontSize: 10,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Baris Data
              ...List.generate(_memberStats.length, (index) {
                final stat = _memberStats[index];
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: stat['initial'] == '-'
                                      ? AppColors.surfaceMuted
                                      : AppColors.primary,
                                  child: Text(
                                    stat['initial'].toString(),
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: stat['initial'] == '-'
                                          ? AppColors.textMuted
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    stat['name'].toString(),
                                    style: AppTextStyles.cardTitle.copyWith(
                                      fontSize: 11,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Center(
                              child: Text(
                                stat['assigned'].toString(),
                                style: AppTextStyles.cardSubtitle.copyWith(
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: Text(
                                stat['completed'].toString(),
                                style: AppTextStyles.cardSubtitle.copyWith(
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildLinearProgressBar(
                                    (stat['percent'] as int) / 100,
                                    AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                SizedBox(
                                  width: 24,
                                  child: Text(
                                    '${stat['percent']}%',
                                    style: AppTextStyles.cardSubtitle.copyWith(
                                      fontSize: 9,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (index < _memberStats.length - 1)
                      Divider(height: 1, color: AppColors.borderLight),
                  ],
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 5. AKTIVITAS TERBARU
        _buildSectionHeader(
          'Aktivitas Terbaru',
          Icons.access_time_rounded,
          onSeeAll: () => _showDummyToast('Lihat riwayat aktivitas'),
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
            children: List.generate(_recentActivities.length, (index) {
              final act = _recentActivities[index];
              final isComplete = act['type'] == 'complete';
              final isMove = act['type'] == 'move';

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isComplete
                                ? AppColors.primarySurface
                                : (isMove
                                      ? const Color(0xFFEFF6FF)
                                      : AppColors.primarySurface),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isComplete
                                ? Icons.check_rounded
                                : (isMove
                                      ? Icons.sync_rounded
                                      : Icons.add_rounded),
                            size: 16,
                            color: isComplete
                                ? AppColors.primary
                                : (isMove
                                      ? const Color(0xFF3B82F6)
                                      : AppColors.primary),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: AppTextStyles.cardTitle.copyWith(
                                    fontSize: 12,
                                  ),
                                  children: [
                                    TextSpan(text: act['name']!),
                                    TextSpan(
                                      text: ' ${act['action']}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                act['task']!,
                                style: AppTextStyles.cardSubtitle.copyWith(
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          act['time']!,
                          style: AppTextStyles.cardSubtitle.copyWith(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (index < _recentActivities.length - 1)
                    Divider(
                      height: 1,
                      color: AppColors.borderLight,
                      indent: 48,
                      endIndent: 16,
                    ),
                ],
              );
            }),
          ),
        ),
        const SizedBox(height: 24),

        // 6. TOMBOL EKSPOR
        OutlinedButton.icon(
          onPressed: () => _showDummyToast('Mengekspor laporan PDF...'),
          icon: const Icon(Icons.download_rounded, size: 18),
          label: const Text(
            'Ekspor Laporan PDF',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: const BorderSide(color: AppColors.primary, width: 1.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            'Laporan akan mencakup seluruh data board',
            style: AppTextStyles.cardSubtitle.copyWith(fontSize: 10),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  // Helper Widget: Kartu Metrik
  Widget _buildMetricCard({
    required IconData icon,
    required String count,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(height: 8),
          Text(count, style: AppTextStyles.cardTitle.copyWith(fontSize: 16)),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.cardSubtitle.copyWith(fontSize: 9),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Helper Widget: Header Seksi
  Widget _buildSectionHeader(
    String title,
    IconData icon, {
    required VoidCallback onSeeAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTextStyles.sectionTitle.copyWith(fontSize: 15),
            ),
          ],
        ),
        GestureDetector(
          onTap: onSeeAll,
          child: Row(
            children: const [
              Text(
                'Lihat Semua',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 2),
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

  // Helper Widget: Progress Bar Linear Round
  Widget _buildLinearProgressBar(
    double progress,
    Color color, {
    double height = 6,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }

  // Helper Widget: Legenda Grafik
  Widget _buildLegendItem(Color color, String label, String count) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.cardSubtitle.copyWith(fontSize: 9),
          ),
        ),
        Text(count, style: AppTextStyles.cardTitle.copyWith(fontSize: 10)),
      ],
    );
  }
}

// ============================================================================
// WIDGET KUSTOM: Grafik Donut Chart (Canvas Painter)
// ============================================================================
class _DonutChartPainter extends CustomPainter {
  final int completed;
  final int inProgress;
  final int notStarted;

  _DonutChartPainter({
    required this.completed,
    required this.inProgress,
    required this.notStarted,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double total = (completed + inProgress + notStarted).toDouble();
    if (total == 0) return;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.butt;

    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Mulai dari atas (Top: -90 derajat)
    double startAngle = -pi / 2;

    // 1. Selesai (Tosca)
    final double sweepCompleted = (completed / total) * 2 * pi;
    paint.color = AppColors.primary;
    canvas.drawArc(rect, startAngle, sweepCompleted, false, paint);
    startAngle += sweepCompleted;

    // 2. Dalam Proses (Biru)
    final double sweepInProgress = (inProgress / total) * 2 * pi;
    paint.color = const Color(0xFF3B82F6);
    canvas.drawArc(rect, startAngle, sweepInProgress, false, paint);
    startAngle += sweepInProgress;

    // 3. Belum Dimulai (Abu-abu muda)
    final double sweepNotStarted = (notStarted / total) * 2 * pi;
    paint.color = const Color(0xFFE2E8F0);
    canvas.drawArc(rect, startAngle, sweepNotStarted, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
