import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../theme/app_theme.dart';

class AttachmentViewer {
  /// Menampilkan gambar layar penuh dengan zoom & tombol download kontras
  static void showImage(
    BuildContext context, {
    required String url,
    required String fileName,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _FullScreenImagePage(url: url, fileName: fileName),
      ),
    );
  }

  /// Menampilkan modal pratinjau dokumen (PDF, DOCX, ZIP, dll.)
  static void showFile(
    BuildContext context, {
    required String url,
    required String fileName,
  }) {
    final String ext = fileName.contains('.')
        ? fileName.split('.').last.toUpperCase()
        : 'FILE';

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        bool isProcessing = false;
        String actionLabel = '';
        double progress = 0.0;

        return StatefulBuilder(
          builder: (ctx, setModalState) {
            Future<void> handleAction({required bool saveToPublic}) async {
              setModalState(() {
                isProcessing = true;
                actionLabel = saveToPublic
                    ? 'Mengunduh'
                    : 'Menyiapkan pratinjau';
                progress = 0.0;
              });

              final savedPath = await downloadFile(
                url: url,
                fileName: fileName,
                saveToPublicDownload: saveToPublic,
                onProgress: (p) {
                  if (ctx.mounted) setModalState(() => progress = p);
                },
              );

              if (ctx.mounted) {
                setModalState(() => isProcessing = false);
              }

              if (savedPath != null) {
                if (sheetCtx.mounted) Navigator.pop(sheetCtx);
                if (!saveToPublic) {
                  // Buka langsung dari folder cache sementara
                  await OpenFilex.open(savedPath);
                } else if (context.mounted) {
                  // Simpan permanen di folder Download HP
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Tersimpan di folder Download: $fileName'),
                      backgroundColor: AppColors.primary,
                      action: SnackBarAction(
                        label: 'BUKA',
                        textColor: Colors.white,
                        onPressed: () => OpenFilex.open(savedPath),
                      ),
                    ),
                  );
                }
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Gagal memproses berkas'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.insert_drive_file_rounded,
                        color: AppColors.primary,
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      fileName,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Format $ext',
                        style: AppTextStyles.cardSubtitle.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (isProcessing) ...[
                      LinearProgressIndicator(
                        value: progress > 0 ? progress : null,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$actionLabel ${(progress * 100).toInt()}%...',
                        style: AppTextStyles.cardSubtitle,
                      ),
                      const SizedBox(height: 12),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: isProcessing
                                ? null
                                : () => handleAction(saveToPublic: false),
                            icon: const Icon(Icons.visibility_outlined),
                            label: const Text('Buka File'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: isProcessing
                                ? null
                                : () => handleAction(saveToPublic: true),
                            icon: const Icon(Icons.download_rounded),
                            label: const Text('Download'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
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

  /// Jika saveToPublicDownload = false -> simpan ke cache sementara (untuk Buka File)
  /// Jika saveToPublicDownload = true  -> simpan permanen ke folder Download HP
  static Future<String?> downloadFile({
    required String url,
    required String fileName,
    bool saveToPublicDownload = true,
    Function(double)? onProgress,
  }) async {
    try {
      Directory? targetDir;
      if (!saveToPublicDownload) {
        targetDir = await getTemporaryDirectory();
      } else {
        if (Platform.isAndroid) {
          final downloadDir = Directory('/storage/emulated/0/Download');
          if (await downloadDir.exists()) {
            targetDir = downloadDir;
          } else {
            targetDir = await getExternalStorageDirectory();
          }
        }
        targetDir ??= await getApplicationDocumentsDirectory();
      }

      final String prefix = saveToPublicDownload
          ? '${DateTime.now().millisecondsSinceEpoch}_'
          : 'preview_';
      final String savePath = '${targetDir.path}/$prefix$fileName';

      await Dio().download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total > 0 && onProgress != null) {
            onProgress(received / total);
          }
        },
      );

      return savePath;
    } catch (e) {
      return null;
    }
  }
}

class _FullScreenImagePage extends StatefulWidget {
  final String url;
  final String fileName;

  const _FullScreenImagePage({required this.url, required this.fileName});

  @override
  State<_FullScreenImagePage> createState() => _FullScreenImagePageState();
}

class _FullScreenImagePageState extends State<_FullScreenImagePage> {
  bool _isDownloading = false;

  Future<void> _downloadImage() async {
    setState(() => _isDownloading = true);
    final savedPath = await AttachmentViewer.downloadFile(
      url: widget.url,
      fileName: widget.fileName,
      saveToPublicDownload: true,
    );
    if (!mounted) return;
    setState(() => _isDownloading = false);

    if (savedPath != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gambar disimpan ke Download: ${widget.fileName}'),
          backgroundColor: AppColors.primary,
          action: SnackBarAction(
            label: 'BUKA',
            textColor: Colors.white,
            onPressed: () => OpenFilex.open(savedPath),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mengunduh gambar'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Widget _buildPillButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24),
      ),
      child: IconButton(
        tooltip: tooltip,
        icon: Icon(icon, color: Colors.white, size: 22),
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        leading: _buildPillButton(
          icon: Icons.close_rounded,
          tooltip: 'Tutup',
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.fileName,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (_isDownloading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.2,
                ),
              ),
            )
          else
            _buildPillButton(
              icon: Icons.download_rounded,
              tooltip: 'Download Gambar',
              onPressed: _downloadImage,
            ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(
            widget.url,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const CircularProgressIndicator(color: Colors.white);
            },
            errorBuilder: (_, __, ___) => const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.broken_image_outlined,
                  color: Colors.white54,
                  size: 48,
                ),
                SizedBox(height: 8),
                Text(
                  'Gagal memuat gambar',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
