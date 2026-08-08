import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../astrology/daily_feature.dart';
import '../astrology/zodiac_sign.dart';
import '../models/celestial_body.dart';
import '../models/icon_display_mode.dart';
import '../theme/celestial_theme.dart';

enum WheelLayoutMode { evenlySpaced, trueLongitude }

/// 今日のホロスコープ画面の中心ウィジェット用ペインター。
class HoroscopeWheelPainter extends CustomPainter {
  final List<CelestialBody> bodies;
  final Map<CelestialBody, double> longitudes;
  final WheelLayoutMode layoutMode;
  final CelestialBody activeBody;
  final CelestialBody featuredBody;
  final FeatureTier? featuredTier;
  final double rotationOffsetDeg;
  final double? ascendantDeg;
  final List<double>? houseCusps;
  final double glowPhase; // 0〜1、明滅アニメーションの位相
  final IconDisplayMode displayMode;
  final bool starMode;
  final double decorRotationDeg; // 装飾用リングの自動回転角(天文データとは無関係)

  HoroscopeWheelPainter({
    required this.bodies,
    required this.longitudes,
    required this.layoutMode,
    required this.activeBody,
    required this.featuredBody,
    this.featuredTier,
    this.rotationOffsetDeg = 0,
    this.ascendantDeg,
    this.houseCusps,
    this.glowPhase = 0,
    this.displayMode = IconDisplayMode.glyph,
    this.starMode = false,
    this.decorRotationDeg = 0,
  });

  double _iconRadius(Size size) => size.width * 0.06;
  double _ringRadius(Size size) => size.width * 0.36;

  double _angleForDeg(double deg) =>
      -math.pi / 2 + (deg + rotationOffsetDeg) * math.pi / 180;

  Offset _positionFor(CelestialBody body, int index, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final ringRadius = _ringRadius(size);
    double baseDeg;
    if (layoutMode == WheelLayoutMode.evenlySpaced) {
      baseDeg = index * (360 / bodies.length);
    } else {
      baseDeg = longitudes[body]!;
    }
    final angle = _angleForDeg(baseDeg);
    return Offset(
      center.dx + ringRadius * math.cos(angle),
      center.dy + ringRadius * math.sin(angle),
    );
  }

  /// タップ位置に該当する天体があれば返す(なければnull)。
  CelestialBody? hitTestBody(Offset localPosition, Size size) {
    final iconRadius = _iconRadius(size);
    final indexOf = {for (var i = 0; i < bodies.length; i++) bodies[i]: i};
    for (final body in bodies) {
      final pos = _positionFor(body, indexOf[body]!, size);
      if ((pos - localPosition).distance <= iconRadius * 1.6) {
        return body;
      }
    }
    return null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final ringRadius = _ringRadius(size);
    final iconRadius = _iconRadius(size);

    final ringPaint = Paint()
      ..color = kGoldAccent.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, ringRadius, ringPaint);

    _drawDecorativeRing(canvas, center, ringRadius, iconRadius);

    if (layoutMode == WheelLayoutMode.trueLongitude) {
      _drawZodiacBand(canvas, center, ringRadius, iconRadius);
      if (ascendantDeg != null && houseCusps != null) {
        _drawHouseCusps(canvas, center, ringRadius);
      }
    }

    final indexOf = {for (var i = 0; i < bodies.length; i++) bodies[i]: i};

    // アクティブな天体を最後に描画し、重なっていても最前面に来るようにする
    final paintOrder = [
      for (final b in bodies)
        if (b != activeBody) b,
      activeBody,
    ];

    final pulse = 0.65 + 0.35 * math.sin(glowPhase * 2 * math.pi);

    for (final body in paintOrder) {
      final isActive = body == activeBody;
      final isFeatured = body == featuredBody;
      final iconCenter = _positionFor(body, indexOf[body]!, size);
      final color = kCelestialColors[body]!;
      final highlight = isActive || isFeatured;

      List<double> glowScales;
      List<double> glowOpacities;
      if (highlight) {
        final tier = isFeatured ? featuredTier : null;
        switch (tier) {
          case FeatureTier.special:
            glowScales = [3.4, 2.6, 1.9];
            glowOpacities = [0.12, 0.20, 0.30];
            break;
          case FeatureTier.notable:
            glowScales = [2.6, 2.0, 1.5];
            glowOpacities = [0.10, 0.18, 0.26];
            break;
          case FeatureTier.regular:
          default:
            glowScales = [2.0, 1.6];
            glowOpacities = [0.10, 0.16];
        }
      } else {
        glowScales = [1.4];
        glowOpacities = [0.10];
      }
      final phase = highlight ? pulse : 1.0;
      for (var j = 0; j < glowScales.length; j++) {
        final glowPaint = Paint()
          ..color = color.withValues(alpha: glowOpacities[j] * phase);
        canvas.drawCircle(iconCenter, iconRadius * glowScales[j], glowPaint);
      }

      final displayColor = highlight ? kGoldAccent : color;

      if (starMode) {
        // 星モード: 円の背景を持たない極小の記号のみ。重なりを減らし、
        // どの宮・どのハウスにいるかが見えるようにする。
        _drawGlyph(
          canvas,
          body,
          iconCenter,
          iconRadius * 0.45,
          displayColor,
        );
      } else if (displayMode == IconDisplayMode.photo) {
        _drawPhotoPlaceholder(canvas, iconCenter, iconRadius, displayColor);
      } else {
        final corePaint = Paint()..color = kBackgroundBottom;
        canvas.drawCircle(iconCenter, iconRadius, corePaint);
        final borderPaint = Paint()
          ..color = displayColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = isActive ? 1.4 : 0.7;
        canvas.drawCircle(iconCenter, iconRadius, borderPaint);
        _drawGlyph(canvas, body, iconCenter, iconRadius, displayColor);
      }
    }
  }

  void _drawZodiacBand(
    Canvas canvas,
    Offset center,
    double ringRadius,
    double iconRadius,
  ) {
    final bandRadius = ringRadius + iconRadius * 2.0;
    final bandPaint = Paint()
      ..color = kGoldAccent.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
    canvas.drawCircle(center, bandRadius, bandPaint);

    for (var i = 0; i < 12; i++) {
      final startDeg = i * 30.0;
      final boundaryAngle = _angleForDeg(startDeg);
      final inner = Offset(
        center.dx + (ringRadius + iconRadius * 1.4) * math.cos(boundaryAngle),
        center.dy + (ringRadius + iconRadius * 1.4) * math.sin(boundaryAngle),
      );
      final outer = Offset(
        center.dx + (bandRadius + 6) * math.cos(boundaryAngle),
        center.dy + (bandRadius + 6) * math.sin(boundaryAngle),
      );
      canvas.drawLine(
        inner,
        outer,
        Paint()
          ..color = kGoldAccent.withValues(alpha: 0.2)
          ..strokeWidth = 0.6,
      );

      final midAngle = _angleForDeg(startDeg + 15);
      final labelPos = Offset(
        center.dx + (bandRadius + 14) * math.cos(midAngle),
        center.dy + (bandRadius + 14) * math.sin(midAngle),
      );
      final label = ZodiacSign.values[i].japaneseName.replaceAll('座', '');
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(color: Color(0xFF8a8a99), fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, labelPos - Offset(tp.width / 2, tp.height / 2));
    }
  }

  void _drawHouseCusps(Canvas canvas, Offset center, double ringRadius) {
    final cusps = houseCusps!;
    for (var i = 0; i < 12; i++) {
      final angle = _angleForDeg(cusps[i]);
      final start = center;
      final end = Offset(
        center.dx + ringRadius * 0.55 * math.cos(angle),
        center.dy + ringRadius * 0.55 * math.sin(angle),
      );
      canvas.drawLine(
        start,
        end,
        Paint()
          ..color = kNatalRingColor.withValues(alpha: 0.25)
          ..strokeWidth = 0.5,
      );

      final labelAngle = _angleForDeg(_wrappedMidpointDeg(cusps[i], cusps[(i + 1) % 12]));
      final labelPos = Offset(
        center.dx + ringRadius * 0.3 * math.cos(labelAngle),
        center.dy + ringRadius * 0.3 * math.sin(labelAngle),
      );
      final tp = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: TextStyle(
            color: kNatalRingColor.withValues(alpha: 0.5),
            fontSize: 9,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, labelPos - Offset(tp.width / 2, tp.height / 2));
    }
  }

  double _wrappedMidpointDeg(double startDeg, double endDeg) {
    var end = endDeg;
    if (end <= startDeg) end += 360; // 0度をまたぐ場合の補正
    return (startDeg + end) / 2 % 360;
  }

  /// 天文データとは無関係に、常時ゆっくり自動回転する装飾用の外周リング。
  void _drawDecorativeRing(
    Canvas canvas,
    Offset center,
    double ringRadius,
    double iconRadius,
  ) {
    final decorRadius = ringRadius + iconRadius * 3.2;
    final basePaint = Paint()
      ..color = kGoldAccent.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
    canvas.drawCircle(center, decorRadius, basePaint);

    // 等間隔の飾り目盛りを回転させる(意味を持たない純粋な演出)
    for (var i = 0; i < 36; i++) {
      final deg = i * 10.0 + decorRotationDeg;
      final angle = -math.pi / 2 + deg * math.pi / 180;
      final inner = Offset(
        center.dx + (decorRadius - 3) * math.cos(angle),
        center.dy + (decorRadius - 3) * math.sin(angle),
      );
      final outer = Offset(
        center.dx + (decorRadius + 3) * math.cos(angle),
        center.dy + (decorRadius + 3) * math.sin(angle),
      );
      canvas.drawLine(
        inner,
        outer,
        Paint()
          ..color = kGoldAccent.withValues(alpha: i % 3 == 0 ? 0.35 : 0.12)
          ..strokeWidth = 0.6,
      );
    }
  }

  void _drawPhotoPlaceholder(
    Canvas canvas,
    Offset c,
    double r,
    Color color,
  ) {
    final fillPaint = Paint()..color = color.withValues(alpha: 0.18);
    canvas.drawCircle(c, r, fillPaint);
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawCircle(c, r, borderPaint);

    // 簡易な人物シルエット(写真未実装のプレースホルダー)
    final silhouettePaint = Paint()..color = color.withValues(alpha: 0.55);
    canvas.drawCircle(c - Offset(0, r * 0.15), r * 0.28, silhouettePaint);
    final shoulders = Path()
      ..addArc(
        Rect.fromCircle(center: c + Offset(0, r * 0.55), radius: r * 0.5),
        math.pi,
        math.pi,
      );
    canvas.drawPath(shoulders, silhouettePaint..style = PaintingStyle.fill);
  }

  void _drawGlyph(
    Canvas canvas,
    CelestialBody body,
    Offset c,
    double r,
    Color color,
  ) {
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
  bool shouldRepaint(covariant HoroscopeWheelPainter oldDelegate) {
    return oldDelegate.layoutMode != layoutMode ||
        oldDelegate.activeBody != activeBody ||
        oldDelegate.featuredBody != featuredBody ||
        oldDelegate.featuredTier != featuredTier ||
        oldDelegate.rotationOffsetDeg != rotationOffsetDeg ||
        oldDelegate.ascendantDeg != ascendantDeg ||
        oldDelegate.glowPhase != glowPhase ||
        oldDelegate.displayMode != displayMode ||
        oldDelegate.starMode != starMode ||
        oldDelegate.decorRotationDeg != decorRotationDeg ||
        oldDelegate.longitudes != longitudes;
  }
}
