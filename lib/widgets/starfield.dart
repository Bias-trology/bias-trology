import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 背景に細かい星々のきらめきを敷く、純粋に装飾用のウィジェット。
/// 天文データとは無関係で、雰囲気作りのみを目的とする。
class Starfield extends StatelessWidget {
  final Animation<double> animation; // 0〜1をループするアニメーション
  final int starCount;

  const Starfield({
    super.key,
    required this.animation,
    this.starCount = 90,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          return CustomPaint(
            size: Size.infinite,
            painter: _StarfieldPainter(phase: animation.value, count: starCount),
          );
        },
      ),
    );
  }
}

class _StarfieldPainter extends CustomPainter {
  final double phase;
  final int count;

  _StarfieldPainter({required this.phase, required this.count});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final random = math.Random(42); // 固定シードで毎フレーム同じ配置にする

    for (var i = 0; i < count; i++) {
      final dx = random.nextDouble() * size.width;
      final dy = random.nextDouble() * size.height;
      final baseRadius = 0.4 + random.nextDouble() * 1.1;
      final twinkleSpeed = 0.6 + random.nextDouble() * 1.8;
      final twinkleOffset = random.nextDouble();
      final twinkle = 0.3 +
          0.7 *
              (0.5 +
                  0.5 *
                      math.sin(
                          (phase * twinkleSpeed + twinkleOffset) * 2 * math.pi));

      final paint = Paint()
        ..color = Colors.white.withValues(alpha: 0.5 * twinkle);
      canvas.drawCircle(Offset(dx, dy), baseRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarfieldPainter oldDelegate) {
    return oldDelegate.phase != phase;
  }
}
