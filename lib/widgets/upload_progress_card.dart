import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../theme/app_theme.dart';

enum UploadStatus { idle, uploading, success, error }

class UploadProgressCard extends StatelessWidget {
  final UploadStatus status;
  final double progress; // 0.0 sampai 1.0
  final String fileName;
  final String? errorMessage;

  const UploadProgressCard({
    super.key,
    required this.status,
    required this.progress,
    required this.fileName,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (status == UploadStatus.idle) return const SizedBox.shrink();

    final int percentInt = (progress * 100).clamp(0, 100).toInt();

    Color accentColor = AppColors.primary;
    String statusText = 'Mengunggah $fileName...';
    if (status == UploadStatus.success) {
      accentColor = AppColors.success;
      statusText = 'Berhasil diunggah!';
    } else if (status == UploadStatus.error) {
      accentColor = AppColors.error;
      statusText = errorMessage ?? 'Gagal mengunggah berkas';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.roundedMd,
        border: Border.all(color: accentColor.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: _buildLeadingIndicator(percentInt, accentColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  status == UploadStatus.uploading
                      ? 'Mohon tunggu sebentar...'
                      : (status == UploadStatus.success
                            ? fileName
                            : 'Periksa koneksi internet dan coba lagi'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.cardSubtitle.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadingIndicator(int percentInt, Color accentColor) {
    if (status == UploadStatus.success) {
      return Container(
        key: const ValueKey('success'),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_circle_rounded,
          color: AppColors.success,
          size: 30,
        ),
      );
    }

    if (status == UploadStatus.error) {
      return Container(
        key: const ValueKey('error'),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.error_rounded,
          color: AppColors.error,
          size: 30,
        ),
      );
    }

    return CircularPercentIndicator(
      key: const ValueKey('uploading'),
      radius: 22.0,
      lineWidth: 4.0,
      percent: progress.clamp(0.0, 1.0),
      animation: true,
      animateFromLastPercent: true,
      animationDuration: 250,
      circularStrokeCap: CircularStrokeCap.round,
      progressColor: accentColor,
      backgroundColor: accentColor.withOpacity(0.15),
      center: Text(
        '$percentInt%',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: accentColor,
        ),
      ),
    );
  }
}
