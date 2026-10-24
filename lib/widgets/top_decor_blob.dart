import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable soft decorative blob widget for the top-right corner of screens,
/// as seen in the TimKerja UI design screenshot.
class TopDecorBlob extends StatelessWidget {
  final double size;
  const TopDecorBlob({super.key, this.size = 140});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -20,
      right: -20,
      child: IgnorePointer(
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _TopDecorBlobPainter(),
          ),
        ),
      ),
    );
  }
}

class _TopDecorBlobPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    final paint2 = Paint()
      ..color = AppColors.primaryLight.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    // Organic petal / curved shape 1
    final path1 = Path();
    path1.moveTo(size.width, 0);
    path1.lineTo(size.width * 0.2, 0);
    path1.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.6,
      size.width,
      size.height * 0.85,
    );
    path1.close();
    canvas.drawPath(path1, paint1);

    // Organic petal / curved shape 2
    final path2 = Path();
    path2.moveTo(size.width, 0);
    path2.lineTo(size.width * 0.45, 0);
    path2.quadraticBezierTo(
      size.width * 0.65,
      size.height * 0.85,
      size.width,
      size.height,
    );
    path2.close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
