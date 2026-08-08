import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/celestial_body.dart';
import '../models/icon_display_mode.dart';

/// 天体記号を1つだけ描画する軽量ウィジェット。
/// Text('♂')等のシステムフォント任せだと、Android等で絵文字カラーフォントに
/// 差し替えられ色指定が効かないことがあるため、Canvas上に自前で線を描く。
class CelestialGlyphIcon extends StatelessWidget {
  final CelestialBody body;
  final double size;
  final Color color;
  final IconDisplayMode displayMode;

  const CelestialGlyphIcon({
    super.key,
    required this.body,
    required this.size,
    required this.color,
    this.displayMode = IconDisplayMode.glyph,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GlyphPainter(
          body: body,
          color: color,
          displayMode: displayMode,
        ),
      ),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  final CelestialBody body;
  final Color color;
  final IconDisplayMode displayMode;

  _GlyphPainter({
    required this.body,
    required this.color,
    required this.displayMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (displayMode == IconDisplayMode.photo) {
      final c = Offset(size.width / 2, size.height / 2);
      final r = size.width / 2;
      canvas.drawCircle(c, r, Paint()..color = color.withValues(alpha: 0.18));
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
      final silhouette = Paint()..color = color.withValues(alpha: 0.55);
      canvas.drawCircle(c - Offset(0, r * 0.15), r * 0.28, silhouette);
      final shoulders = Path()
        ..addArc(
          Rect.fromCircle(center: c + Offset(0, r * 0.55), radius: r * 0.5),
          math.pi,
          math.pi,
        );
      canvas.drawPath(shoulders, silhouette..style = PaintingStyle.fill);
      return;
    }
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.16
      ..strokeCap = StrokeCap.round;

    switch (body) {
      case CelestialBody.sun:
        canvas.drawCircle(c, r * 0.5, paint);
        canvas.drawCircle(c, r * 0.1, paint..style = PaintingStyle.fill);
        break;

      case CelestialBody.moon:
        final outer = Path()
          ..addOval(Rect.fromCircle(center: c, radius: r * 0.55));
        final inner = Path()
          ..addOval(Rect.fromCircle(
              center: c + Offset(r * 0.3, 0), radius: r * 0.5));
        final crescent = Path.combine(PathOperation.difference, outer, inner);
        canvas.drawPath(crescent, paint..style = PaintingStyle.fill);
        break;

      case CelestialBody.mercury:
        final hornRect = Rect.fromCenter(
          center: c + Offset(0, -r * 0.55),
          width: r * 0.5,
          height: r * 0.45,
        );
        canvas.drawArc(hornRect, math.pi, math.pi, false, paint);
        canvas.drawCircle(c - Offset(0, r * 0.05), r * 0.3, paint);
        canvas.drawLine(
            c + Offset(0, r * 0.25), c + Offset(0, r * 0.6), paint);
        canvas.drawLine(c + Offset(-r * 0.17, r * 0.42),
            c + Offset(r * 0.17, r * 0.42), paint);
        break;

      case CelestialBody.venus:
        canvas.drawCircle(c + Offset(0, -r * 0.15), r * 0.35, paint);
        canvas.drawLine(
            c + Offset(0, r * 0.2), c + Offset(0, r * 0.62), paint);
        canvas.drawLine(c + Offset(-r * 0.2, r * 0.42),
            c + Offset(r * 0.2, r * 0.42), paint);
        break;

      case CelestialBody.mars:
        canvas.drawCircle(c + Offset(-r * 0.12, r * 0.12), r * 0.32, paint);
        final start = c + Offset(r * 0.1, -r * 0.1);
        final end = c + Offset(r * 0.55, -r * 0.55);
        canvas.drawLine(start, end, paint);
        canvas.drawLine(end, end + Offset(-r * 0.22, 0), paint);
        canvas.drawLine(end, end + Offset(0, r * 0.22), paint);
        break;

      case CelestialBody.jupiter:
        final path = Path()
          ..moveTo(c.dx - r * 0.35, c.dy - r * 0.5)
          ..quadraticBezierTo(c.dx - r * 0.55, c.dy - r * 0.1, c.dx - r * 0.05,
              c.dy - r * 0.05)
          ..moveTo(c.dx + r * 0.3, c.dy - r * 0.5)
          ..lineTo(c.dx + r * 0.3, c.dy + r * 0.55)
          ..moveTo(c.dx - r * 0.15, c.dy - r * 0.05)
          ..lineTo(c.dx + r * 0.5, c.dy - r * 0.05);
        canvas.drawPath(path, paint);
        break;

      case CelestialBody.saturn:
        final path = Path()
          ..moveTo(c.dx - r * 0.35, c.dy - r * 0.55)
          ..lineTo(c.dx - r * 0.35, c.dy + r * 0.1)
          ..moveTo(c.dx - r * 0.55, c.dy - r * 0.3)
          ..lineTo(c.dx - r * 0.15, c.dy - r * 0.3)
          ..moveTo(c.dx - r * 0.35, c.dy + r * 0.1)
          ..quadraticBezierTo(c.dx - r * 0.35, c.dy + r * 0.55, c.dx + r * 0.05,
              c.dy + r * 0.45);
        canvas.drawPath(path, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _GlyphPainter oldDelegate) {
    return oldDelegate.body != body ||
        oldDelegate.color != color ||
        oldDelegate.displayMode != displayMode;
  }
}
