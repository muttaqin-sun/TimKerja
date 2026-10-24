import 'dart:math' as math;
import 'package:flutter/material.dart';

class GoogleIcon extends StatelessWidget {
  final double size;

  const GoogleIcon({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double center = size.width / 2;
    final double radius = size.width / 2;
    final double strokeWidth = size.width * 0.22;
    final Rect rect = Rect.fromCircle(
      center: Offset(center, center),
      radius: radius - strokeWidth / 2,
    );

    final Paint bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.square;

    final Paint greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.square;

    final Paint yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.square;

    final Paint redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.square;

    // Draw Google arcs
    // Red Arc (Top)
    canvas.drawArc(rect, -math.pi * 0.75, math.pi * 0.52, false, redPaint);

    // Yellow Arc (Left)
    canvas.drawArc(rect, -math.pi * 1.25, math.pi * 0.52, false, yellowPaint);

    // Green Arc (Bottom)
    canvas.drawArc(rect, math.pi * 0.25, math.pi * 0.52, false, greenPaint);

    // Blue Arc (Right side)
    canvas.drawArc(rect, -math.pi * 0.25, math.pi * 0.52, false, bluePaint);

    // Blue Horizontal Bar
    final Paint blueFill = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    final double barHeight = strokeWidth;
    final Rect barRect = Rect.fromLTWH(
      center - strokeWidth * 0.2,
      center - barHeight / 2,
      radius + strokeWidth * 0.2,
      barHeight,
    );
    canvas.drawRect(barRect, blueFill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
