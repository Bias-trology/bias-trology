import 'julian_day.dart';
import 'math_utils.dart';

/// グリニッジ平均恒星時(度)。ユリウス日から求める(Meeus低精度式)。
double greenwichMeanSiderealTimeDeg(double jd) {
  final t = centuriesSinceJ2000(jd);
  final gmst = 280.46061837 +
      360.98564736629 * (jd - 2451545.0) +
      0.000387933 * t * t -
      (t * t * t) / 38710000;
  return normalizeDegrees(gmst);
}

/// 黄道傾斜角(度)。J2000元期からの低次補正式。
double obliquityOfEclipticDeg(double centuriesSinceJ2000Value) {
  final t = centuriesSinceJ2000Value;
  return 23.439291111 -
      0.013004167 * t -
      0.000000164 * t * t +
      0.000000504 * t * t * t;
}

/// アセンダント(黄経、度)を求める。
/// [jd]: ユリウス日(UTC基準)
/// [longitudeDeg]: 観測地の経度(東経+、西経-)
/// [latitudeDeg]: 観測地の緯度(北緯+、南緯-)
double computeAscendantDeg(
  double jd,
  double longitudeDeg,
  double latitudeDeg,
) {
  final gmst = greenwichMeanSiderealTimeDeg(jd);
  final ramc = normalizeDegrees(gmst + longitudeDeg); // ローカル恒星時
  final eps = obliquityOfEclipticDeg(centuriesSinceJ2000(jd));

  final y = cosDeg(ramc);
  final x = -(sinDeg(ramc) * cosDeg(eps) + tanDeg(latitudeDeg) * sinDeg(eps));

  return normalizeDegrees(atan2Deg(y, x));
}

/// イコールハウス(等分室)方式で、アセンダントから12ハウスの境界(黄経、度)を求める。
/// 添字0が第1ハウスの始点(=アセンダントそのもの)。
List<double> computeEqualHouseCusps(double ascendantDeg) {
  return List.generate(12, (i) => normalizeDegrees(ascendantDeg + i * 30));
}

/// ある黄経が第何ハウス(1〜12)に入るかを求める。
int houseNumberForLongitude(double longitudeDeg, List<double> cusps) {
  final lon = normalizeDegrees(longitudeDeg);
  for (var i = 0; i < 12; i++) {
    final start = cusps[i];
    final end = cusps[(i + 1) % 12];
    if (start < end) {
      if (lon >= start && lon < end) return i + 1;
    } else {
      // 0度をまたぐハウス
      if (lon >= start || lon < end) return i + 1;
    }
  }
  return 12;
}
