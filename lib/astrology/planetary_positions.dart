import '../models/celestial_body.dart';
import 'julian_day.dart';
import 'math_utils.dart';
import 'moon_position.dart';
import 'orbital_elements.dart';

/// 指定した日時(UTC)における7天体の地心黄経(度)をまとめて返す。
///
/// 重要: [utcDateTime] は必ずUTCで渡すこと。ユーザーの出生時刻など
/// ローカルタイムゾーンで入力された日時は、呼び出し側であらかじめ
/// UTCに変換してから渡す必要がある。
Map<CelestialBody, double> computeGeocentricLongitudes(DateTime utcDateTime) {
  final jd = toJulianDay(utcDateTime);
  final t = centuriesSinceJ2000(jd);

  final earth = earthElements.heliocentricPositionAt(t);

  // 太陽の地心黄経 = 地球から見て太陽の方向(地球の太陽中心黄経+180度)
  final sunLongitude = normalizeDegrees(atan2Deg(-earth.y, -earth.x));

  final moonLongitude = computeMoonEclipticLongitude(t);

  final mercuryLongitude =
      (mercuryElements.heliocentricPositionAt(t) - earth).eclipticLongitudeDeg;
  final venusLongitude =
      (venusElements.heliocentricPositionAt(t) - earth).eclipticLongitudeDeg;
  final marsLongitude =
      (marsElements.heliocentricPositionAt(t) - earth).eclipticLongitudeDeg;
  final jupiterLongitude =
      (jupiterElements.heliocentricPositionAt(t) - earth).eclipticLongitudeDeg;
  final saturnLongitude =
      (saturnElements.heliocentricPositionAt(t) - earth).eclipticLongitudeDeg;

  return {
    CelestialBody.sun: sunLongitude,
    CelestialBody.moon: moonLongitude,
    CelestialBody.mercury: mercuryLongitude,
    CelestialBody.venus: venusLongitude,
    CelestialBody.mars: marsLongitude,
    CelestialBody.jupiter: jupiterLongitude,
    CelestialBody.saturn: saturnLongitude,
  };
}
