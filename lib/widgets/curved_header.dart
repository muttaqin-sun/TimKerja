import 'package:flutter/material.dart';

class CurvedAuthHeader extends StatelessWidget {
  final VoidCallback? onBack;
  final double height;

  const CurvedAuthHeader({super.key, this.onBack, this.height = 100});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          // Background soft transparent blobs
          CustomPaint(
            size: Size(double.infinity, height),
            painter: _SoftBlobPainter(),
          ),
          // Back Button (Tosca on transparent)
          if (onBack != null)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, top: 16),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF00A896),
                    size: 24,
                  ),
                  onPressed: onBack,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SoftBlobPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFF00A896).withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    // Soft blob di kanan atas
    canvas.drawCircle(Offset(size.width * 0.85, -20), 120, paint);
    // Soft blob kecil di tengah atas
    canvas.drawCircle(Offset(size.width * 0.4, -40), 60, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BottomDecorativeWaves extends StatelessWidget {
  const BottomDecorativeWaves({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: 150,
      child: IgnorePointer(
        child: CustomPaint(
          size: const Size(double.infinity, 150),
          painter: _BottomBlobPainter(),
        ),
      ),
    );
  }
}

class _BottomBlobPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFF00A896).withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    // Soft blob di kiri bawah dan kanan bawah
    canvas.drawCircle(Offset(size.width * 0.1, size.height + 20), 100, paint);
    canvas.drawCircle(Offset(size.width * 0.9, size.height + 40), 130, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
