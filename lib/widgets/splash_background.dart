import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SplashBackground extends StatelessWidget {
  final Widget child;

  const SplashBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppGradients.splashGradient,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background organic curves
          CustomPaint(
            painter: _SplashCurvesPainter(),
          ),
          child,
        ],
      ),
    );
  }
}

class _SplashCurvesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Top-left soft wave
    final Paint wave1 = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    final Path path1 = Path();
    path1.moveTo(0, size.height * 0.35);
    path1.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.28,
      size.width * 0.45,
      0,
    );
    path1.lineTo(0, 0);
    path1.close();
    canvas.drawPath(path1, wave1);

    // Top-right soft wave
    final Paint wave2 = Paint()
      ..color = AppColors.waveOverlay1
      ..style = PaintingStyle.fill;

    final Path path2 = Path();
    path2.moveTo(size.width * 0.3, 0);
    path2.quadraticBezierTo(
      size.width * 0.7,
      size.height * 0.25,
      size.width,
      size.height * 0.18,
    );
    path2.lineTo(size.width, 0);
    path2.close();
    canvas.drawPath(path2, wave2);

    // Bottom-left soft wave
    final Paint wave3 = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;

    final Path path3 = Path();
    path3.moveTo(0, size.height * 0.65);
    path3.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.72,
      size.width * 0.2,
      size.height,
    );
    path3.lineTo(0, size.height);
    path3.close();
    canvas.drawPath(path3, wave3);

    // Bottom-right soft wave
    final Paint wave4 = Paint()
      ..color = AppColors.waveOverlay2
      ..style = PaintingStyle.fill;

    final Path path4 = Path();
    path4.moveTo(size.width * 0.4, size.height);
    path4.quadraticBezierTo(
      size.width * 0.65,
      size.height * 0.78,
      size.width,
      size.height * 0.85,
    );
    path4.lineTo(size.width, size.height);
    path4.close();
    canvas.drawPath(path4, wave4);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
