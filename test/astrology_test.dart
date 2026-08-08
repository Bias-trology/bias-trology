import 'package:flutter_test/flutter_test.dart';
import 'package:oshi_uranai/astrology/aspect_calculator.dart';
import 'package:oshi_uranai/astrology/planetary_positions.dart';
import 'package:oshi_uranai/astrology/zodiac_sign.dart';
import 'package:oshi_uranai/models/aspect_type.dart';
import 'package:oshi_uranai/models/celestial_body.dart';

void main() {
  group('天体位置計算', () {
    test('2026年8月8日の各天体の黄経・星座を出力して目視確認する', () {
      final utc = DateTime.utc(2026, 8, 8, 12, 0, 0);
      final positions = computeGeocentricLongitudes(utc);

      for (final body in CelestialBody.values) {
        final lon = positions[body]!;
        final sign = zodiacSignFromLongitude(lon);
        // ignore: avoid_print
        print(
            '${body.japaneseName}: 黄経 ${lon.toStringAsFixed(2)}度 → ${sign.japaneseName}');
      }

      // サニティチェック: 8月8日時点の太陽は獅子座(黄経120〜150度)にあるはず
      final sunLongitude = positions[CelestialBody.sun]!;
      expect(zodiacSignFromLongitude(sunLongitude), ZodiacSign.leo);
      expect(sunLongitude, greaterThan(120));
      expect(sunLongitude, lessThan(150));
    });

    test('木星と土星の黄経が大きく違う(周期の違いを反映しているか)', () {
      final utc = DateTime.utc(2026, 8, 8, 12, 0, 0);
      final positions = computeGeocentricLongitudes(utc);
      // 木星・土星は動きが遅いので、同じ日でも黄経は離れた値になっているはず
      // (少なくとも別のサインになっている可能性が高いことの緩い確認)
      expect(
        positions[CelestialBody.jupiter],
        isNot(closeTo(positions[CelestialBody.saturn]!, 1.0)),
      );
    });
  });

  group('アスペクト判定', () {
    test('90度離れた2点はスクエアと判定される', () {
      final hit = findAspect(10, 100, orb: 6);
      expect(hit, isNotNull);
      expect(hit!.type, AspectType.square);
    });

    test('180度離れた2点は衝と判定される', () {
      final hit = findAspect(10, 190, orb: 6);
      expect(hit, isNotNull);
      expect(hit!.type, AspectType.opposition);
    });

    test('orb範囲外なら何も返さない', () {
      final hit = findAspect(0, 45, orb: 6);
      expect(hit, isNull);
    });

    test('同じ黄経(0度差)は合と判定される', () {
      final hit = findAspect(123.4, 123.9, orb: 6);
      expect(hit, isNotNull);
      expect(hit!.type, AspectType.conjunction);
    });
  });
}
