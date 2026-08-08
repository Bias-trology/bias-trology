import 'package:flutter/material.dart';

import '../astrology/houses.dart';
import '../astrology/zodiac_sign.dart';
import '../models/celestial_body.dart';
import '../theme/celestial_theme.dart';
import 'celestial_glyph_icon.dart';

/// 星モード用: 7天体の現在位置情報(星座・度数・ハウス)をまとめた一覧表。
class CelestialDataTable extends StatelessWidget {
  final Map<CelestialBody, double> longitudes;
  final List<double>? houseCusps;

  const CelestialDataTable({
    super.key,
    required this.longitudes,
    this.houseCusps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kBackgroundTop,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kGoldAccent.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          for (final body in CelestialBody.values) _row(body),
        ],
      ),
    );
  }

  Widget _row(CelestialBody body) {
    final lon = longitudes[body]!;
    final sign = zodiacSignFromLongitude(lon);
    final degreeInSign = lon % 30;
    final house = houseCusps != null
        ? houseNumberForLongitude(lon, houseCusps!)
        : null;
    final color = kCelestialColors[body]!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CelestialGlyphIcon(body: body, size: 22, color: color),
          const SizedBox(width: 10),
          SizedBox(
            width: 40,
            child: Text(
              body.japaneseName,
              style: TextStyle(color: color, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              '${sign.japaneseName} ${degreeInSign.toStringAsFixed(1)}度'
              '${house != null ? '  第$house室' : ''}',
              style: const TextStyle(color: Color(0xFFbdbdc9), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
