import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/app_data.dart';

class PdfReportService {
  /// Generate dan cetak / preview dokumen laporan kegiatan/projek
  static Future<void> generateAndPreviewBoardReport({
    required String boardId,
    required String boardTitle,
  }) async {
    final pdfBytes = await buildBoardReportPdf(
      boardId: boardId,
      boardTitle: boardTitle,
    );

    // Buka dialog preview / cetak / download PDF
    await Printing.layoutPdf(
      name: 'Laporan_Proyek_${boardTitle.replaceAll(RegExp(r'\s+'), '_')}.pdf',
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  }

  /// Membuat Uint8List dokumen PDF laporan lengkap
  static Future<Uint8List> buildBoardReportPdf({
    required String boardId,
    required String boardTitle,
  }) async {
    final pdf = pw.Document();

    // 1. Ambil data Board & Task terkait dari AppDataController
    final board = AppDataController.instance.boards.firstWhere(
      (b) => b['id'] == boardId,
      orElse: () => {'title': boardTitle, 'lists': <String>[]},
    );
    final List<String> boardLists = List<String>.from(board['lists'] ?? []);
    final List<Map<String, dynamic>> boardTasks = AppDataController.instance.tasks
        .where((t) => t['boardId'] == boardId)
      .cast<Map<String, dynamic>>()
        .toList();

    final String leaderName = AppDataController.instance.currentUserProfile['name'] ?? 'Ketua Pelaksana';

    // Format tanggal sekarang
    final now = DateTime.now();
    final List<String> monthNames = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final String formattedDate = '${now.day} ${monthNames[now.month]} ${now.year}';

    // 2. Load Logo TimKerja dari folder assets khusus
    pw.MemoryImage? logoImage;
    try {
      final ByteData imageByteData = await rootBundle.load('assets/images/report/logo_timkerja.png');
      final Uint8List imageBytes = imageByteData.buffer.asUint8List();
      logoImage = pw.MemoryImage(imageBytes);
    } catch (_) {
      // Jika logo belum tersedia/gagal load, dokumen tetap dapat digenerate
      logoImage = null;
    }

    // 3. Hitung Rekapitulasi per List (List -> Task Selesai -> % Subtask Selesai)
    final List<List<String>> summaryRows = [];
    int totalBoardTasks = 0;
    int totalBoardDoneTasks = 0;

    for (final listName in boardLists) {
      final tasksInList = boardTasks.where((t) => t['listName'] == listName).toList();
      final totalInList = tasksInList.length;
      final doneInList = tasksInList.where((t) => t['isDone'] == true).length;

      totalBoardTasks += totalInList;
      totalBoardDoneTasks += doneInList;

      // Hitung progress subtask dalam list ini
      int totalSubtasks = 0;
      int doneSubtasks = 0;

      for (final task in tasksInList) {
        final subtasks = (task['subtasks'] as List?) ?? [];
        totalSubtasks += subtasks.length;
        doneSubtasks += subtasks.where((s) => s['isDone'] == true).length;
      }

      final String subtaskPercentage = totalSubtasks == 0
          ? '-'
          : '${((doneSubtasks / totalSubtasks) * 100).toStringAsFixed(0)}%';

      final String taskStatusString = totalInList == 0
          ? '0%'
          : '${((doneInList / totalInList) * 100).toStringAsFixed(0)}%';

      summaryRows.add([
        listName,
        '$doneInList dari $totalInList',
        taskStatusString,
        totalSubtasks == 0 ? '-' : '$doneSubtasks dari $totalSubtasks ($subtaskPercentage)',
      ]);
    }

    // 4. Bangun Halaman Cover & Ringkasan (Sesuai Desain Foto)
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Kop Dokumen (Tengah)
              pw.Center(
                child: pw.Column(
                  children: [
                    if (logoImage != null)
                      pw.Container(
                        width: 55,
                        height: 55,
                        margin: const pw.EdgeInsets.only(bottom: 8),
                        child: pw.Image(logoImage),
                      )
                    else
                      pw.Container(
                        width: 48,
                        height: 48,
                        margin: const pw.EdgeInsets.only(bottom: 8),
                        decoration: pw.BoxDecoration(
                          shape: pw.BoxShape.circle,
                          color: PdfColor.fromHex('0F766E'),
                        ),
                        child: pw.Center(
                          child: pw.Text(
                            'TK',
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    pw.Text(
                      'TIMKERJA',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 1.5,
                        color: PdfColor.fromHex('1F2937'),
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      'LAPORAN KEGIATAN PROYEK',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('4B5563'),
                        letterSpacing: 0.8,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Container(
                      height: 1.5,
                      color: PdfColor.fromHex('0F766E'),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 22),

              // Metadata Proyek (Rata Kiri)
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('F9FAFB'),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  border: pw.Border.all(color: PdfColor.fromHex('E5E7EB')),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      children: [
                        pw.SizedBox(
                          width: 130,
                          child: pw.Text(
                            'Nama Kegiatan / Board',
                            style: pw.TextStyle(color: PdfColor.fromHex('6B7280'), fontSize: 10),
                          ),
                        ),
                        pw.Text(': ', style: pw.TextStyle(color: PdfColor.fromHex('6B7280'), fontSize: 10)),
                        pw.Text(
                          boardTitle,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 5),
                    pw.Row(
                      children: [
                        pw.SizedBox(
                          width: 130,
                          child: pw.Text(
                            'Tanggal Laporan',
                            style: pw.TextStyle(color: PdfColor.fromHex('6B7280'), fontSize: 10),
                          ),
                        ),
                        pw.Text(': ', style: pw.TextStyle(color: PdfColor.fromHex('6B7280'), fontSize: 10)),
                        pw.Text(formattedDate, style: const pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                    pw.SizedBox(height: 5),
                    pw.Row(
                      children: [
                        pw.SizedBox(
                          width: 130,
                          child: pw.Text(
                            'Ketua Pelaksana',
                            style: pw.TextStyle(color: PdfColor.fromHex('6B7280'), fontSize: 10),
                          ),
                        ),
                        pw.Text(': ', style: pw.TextStyle(color: PdfColor.fromHex('6B7280'), fontSize: 10)),
                        pw.Text(leaderName, style: const pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Judul Bagian Rekapitulasi
              pw.Text(
                'Rekapitulasi Kolom List',
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('111827'),
                ),
              ),
              pw.SizedBox(height: 8),

              // Tabel Rekapitulasi (Sesuai Foto tetapi adaptif Board-List-Task-Subtask)
              if (summaryRows.isEmpty)
                pw.Text(
                  'Belum ada list di board ini.',
                  style: pw.TextStyle(fontSize: 10, color: PdfColor.fromHex('9CA3AF')),
                )
              else
                pw.TableHelper.fromTextArray(
                  headers: ['Kolom List', 'Tugas Selesai', 'Status Task', 'Progress Sub-task'],
                  data: summaryRows,
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                    color: PdfColor.fromHex('111827'),
                  ),
                  headerDecoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('F3F4F6'),
                  ),
                  cellStyle: const pw.TextStyle(fontSize: 9),
                  cellHeight: 25,
                  cellAlignments: {
                    0: pw.Alignment.centerLeft,
                    1: pw.Alignment.center,
                    2: pw.Alignment.center,
                    3: pw.Alignment.center,
                  },
                ),

              pw.SizedBox(height: 14),

              // Ringkasan Persentase Total
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Total Keseluruhan: $totalBoardDoneTasks dari $totalBoardTasks Tugas Selesai (${totalBoardTasks == 0 ? 0 : ((totalBoardDoneTasks / totalBoardTasks) * 100).toStringAsFixed(1)}%)',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('0F766E'),
                  ),
                ),
              ),

              pw.Spacer(),

              // Footer Catatan
              pw.Divider(color: PdfColor.fromHex('E5E7EB')),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Dokumen resmi digenerate otomatis oleh TimKerja App',
                    style: pw.TextStyle(fontSize: 8, color: PdfColor.fromHex('9CA3AF')),
                  ),
                  pw.Text(
                    'Halaman 1',
                    style: pw.TextStyle(fontSize: 8, color: PdfColor.fromHex('9CA3AF')),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    // 5. Halaman Detail Rincian: Board -> List -> Task -> Sub-task
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        header: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 8),
            margin: const pw.EdgeInsets.only(bottom: 12),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.8),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Rincian Tugas & Sub-task: $boardTitle',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('4B5563'),
                  ),
                ),
                pw.Text(
                  formattedDate,
                  style: pw.TextStyle(fontSize: 9, color: PdfColor.fromHex('9CA3AF')),
                ),
              ],
            ),
          );
        },
        build: (pw.Context context) {
          final List<pw.Widget> contentWidgets = [];

          for (final listName in boardLists) {
            final tasksInList = boardTasks.where((t) => t['listName'] == listName).toList();

            contentWidgets.add(
              pw.Container(
                margin: const pw.EdgeInsets.only(top: 10, bottom: 6),
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('E6FFFA'),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Text(
                  'Kolom: $listName (${tasksInList.length} Tugas)',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('0F766E'),
                  ),
                ),
              ),
            );

            if (tasksInList.isEmpty) {
              contentWidgets.add(
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 8, bottom: 8),
                  child: pw.Text(
                    'Tidak ada tugas pada kolom ini.',
                    style: pw.TextStyle(fontSize: 9, color: PdfColor.fromHex('9CA3AF')),
                  ),
                ),
              );
            } else {
              for (final task in tasksInList) {
                final bool isTaskDone = task['isDone'] ?? false;
                final String priority = task['priority'] ?? 'Low';
                final String status = task['status'] ?? (isTaskDone ? 'Done' : 'To Do');
                final String dueDate = task['dueDate'] ?? task['date'] ?? '-';
                final subtasks = (task['subtasks'] as List?) ?? [];

                contentWidgets.add(
                  pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 8),
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('FAFAFA'),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                      border: pw.Border.all(color: PdfColor.fromHex('E5E7EB')),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Baris Judul Task & Status Badge
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                '${isTaskDone ? "[V] " : "[ ] "} ${task['title']}',
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                  color: isTaskDone ? PdfColor.fromHex('4B5563') : PdfColor.fromHex('111827'),
                                ),
                              ),
                            ),
                            pw.Text(
                              'Status: $status | Prioritas: $priority | Deadline: $dueDate',
                              style: pw.TextStyle(fontSize: 8, color: PdfColor.fromHex('6B7280')),
                            ),
                          ],
                        ),

                        // Subtasks List
                        if (subtasks.isNotEmpty) ...[
                          pw.SizedBox(height: 6),
                          pw.Container(
                            padding: const pw.EdgeInsets.only(left: 8),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: subtasks.map((st) {
                                final bool isSubDone = st['isDone'] ?? false;
                                return pw.Padding(
                                  padding: const pw.EdgeInsets.only(bottom: 2),
                                  child: pw.Row(
                                    children: [
                                      pw.Text(
                                        isSubDone ? '  • [V] ' : '  • [ ] ',
                                        style: pw.TextStyle(
                                          fontSize: 8,
                                          fontWeight: pw.FontWeight.bold,
                                          color: isSubDone ? PdfColor.fromHex('10B981') : PdfColor.fromHex('9CA3AF'),
                                        ),
                                      ),
                                      pw.Text(
                                        st['title'] ?? '',
                                        style: pw.TextStyle(
                                          fontSize: 8,
                                          color: isSubDone ? PdfColor.fromHex('6B7280') : PdfColor.fromHex('1F2937'),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }
            }
          }

          return contentWidgets;
        },
      ),
    );

    return pdf.save();
  }
}
