import 'dart:math' as math;

import 'math_utils.dart';

/// ケプラー軌道要素(JPL低精度軌道要素表, J2000.0元期、有効期間おおよそ1800〜2050年)。
/// 出典: NASA/JPL Solar System Dynamics group が公開する近似軌道要素セット。
/// a: 軌道長半径(AU), e: 離心率, i: 軌道傾斜角(度), L: 平均黄経(度),
/// peri: 近日点黄経(度), node: 昇交点黄経(度)。
/// 各要素は「元期の値」+「1世紀あたりの変化率」で表される。
class OrbitalElements {
  final double a0, aDot;
  final double e0, eDot;
  final double i0, iDot;
  final double l0, lDot;
  final double peri0, periDot;
  final double node0, nodeDot;

  const OrbitalElements({
    required this.a0,
    required this.aDot,
    required this.e0,
    required this.eDot,
    required this.i0,
    required this.iDot,
    required this.l0,
    required this.lDot,
    required this.peri0,
    required this.periDot,
    required this.node0,
    required this.nodeDot,
  });

  /// 世紀数Tにおける太陽中心黄道座標(AU)を返す。
  Vector3 heliocentricPositionAt(double t) {
    final a = a0 + aDot * t;
    final e = e0 + eDot * t;
    final i = i0 + iDot * t;
    final l = l0 + lDot * t;
    final peri = peri0 + periDot * t;
    final node = node0 + nodeDot * t;
    final omega = peri - node; // 近日点引数

    // 平均近点角(-180〜180度に正規化)
    final m = normalizeDegrees180(l - peri);

    // ケプラー方程式 M = E - e*sin(E) をニュートン法で解く(度単位、Standish方式)
    final eStar = e * 180.0 / 3.141592653589793;
    double ecc = m + eStar * sinDeg(m);
    for (var iter = 0; iter < 12; iter++) {
      final deltaM = m - (ecc - eStar * sinDeg(ecc));
      final deltaE = deltaM / (1 - e * cosDeg(ecc));
      ecc += deltaE;
      if (deltaE.abs() < 1e-7) break;
    }

    // 軌道面上の座標
    final xPrime = a * (cosDeg(ecc) - e);
    final yPrime = a * math.sqrt(1 - e * e) * sinDeg(ecc);

    // 黄道座標系への回転
    final x = (cosDeg(omega) * cosDeg(node) -
                sinDeg(omega) * sinDeg(node) * cosDeg(i)) *
            xPrime +
        (-sinDeg(omega) * cosDeg(node) -
                cosDeg(omega) * sinDeg(node) * cosDeg(i)) *
            yPrime;
    final y = (cosDeg(omega) * sinDeg(node) +
                sinDeg(omega) * cosDeg(node) * cosDeg(i)) *
            xPrime +
        (-sinDeg(omega) * sinDeg(node) +
                cosDeg(omega) * cosDeg(node) * cosDeg(i)) *
            yPrime;
    final z = (sinDeg(omega) * sinDeg(i)) * xPrime +
        (cosDeg(omega) * sinDeg(i)) * yPrime;

    return Vector3(x, y, z);
  }
}

/// 地球(地球-月重心)の軌道要素。太陽・他惑星の地心黄経を求める基準に使う。
const earthElements = OrbitalElements(
  a0: 1.00000261, aDot: 0.00000562,
  e0: 0.01671123, eDot: -0.00004392,
  i0: -0.00001531, iDot: -0.01294668,
  l0: 100.46457166, lDot: 35999.37244981,
  peri0: 102.93768193, periDot: 0.32327364,
  node0: 0.0, nodeDot: 0.0,
);

const mercuryElements = OrbitalElements(
  a0: 0.38709927, aDot: 0.00000037,
  e0: 0.20563593, eDot: 0.00001906,
  i0: 7.00497902, iDot: -0.00594749,
  l0: 252.25032350, lDot: 149472.67411175,
  peri0: 77.45779628, periDot: 0.16047689,
  node0: 48.33076593, nodeDot: -0.12534081,
);

const venusElements = OrbitalElements(
  a0: 0.72333566, aDot: 0.00000390,
  e0: 0.00677672, eDot: -0.00004107,
  i0: 3.39467605, iDot: -0.00078890,
  l0: 181.97909950, lDot: 58517.81538729,
  peri0: 131.60246718, periDot: 0.00268329,
  node0: 76.67984255, nodeDot: -0.27769418,
);

const marsElements = OrbitalElements(
  a0: 1.52371034, aDot: 0.00001847,
  e0: 0.09339410, eDot: 0.00007882,
  i0: 1.84969142, iDot: -0.00813131,
  l0: -4.55343205, lDot: 19140.30268499,
  peri0: -23.94362959, periDot: 0.44441088,
  node0: 49.55953891, nodeDot: -0.29257343,
);

const jupiterElements = OrbitalElements(
  a0: 5.20288700, aDot: -0.00011607,
  e0: 0.04838624, eDot: -0.00013253,
  i0: 1.30439695, iDot: -0.00183714,
  l0: 34.39644051, lDot: 3034.74612775,
  peri0: 14.72847983, periDot: 0.21252668,
  node0: 100.47390909, nodeDot: 0.20469106,
);

const saturnElements = OrbitalElements(
  a0: 9.53667594, aDot: -0.00125060,
  e0: 0.05386179, eDot: -0.00050991,
  i0: 2.48599187, iDot: 0.00193609,
  l0: 49.95424423, lDot: 1222.49362201,
  peri0: 92.59887831, periDot: -0.41897216,
  node0: 113.66242448, nodeDot: -0.28867794,
);
