import 'dart:math' as math;

/// 3次元ベクトル(黄道座標系での位置計算に使う)。
class Vector3 {
  final double x;
  final double y;
  final double z;

  const Vector3(this.x, this.y, this.z);

  Vector3 operator -(Vector3 other) =>
      Vector3(x - other.x, y - other.y, z - other.z);

  /// このベクトルをxy平面(黄道面)に投影した黄経(0〜360度)。
  double get eclipticLongitudeDeg => normalizeDegrees(atan2Deg(y, x));
}

double degToRad(double deg) => deg * math.pi / 180.0;

double radToDeg(double rad) => rad * 180.0 / math.pi;

double sinDeg(double deg) => math.sin(degToRad(deg));

double cosDeg(double deg) => math.cos(degToRad(deg));

double tanDeg(double deg) => math.tan(degToRad(deg));

double atan2Deg(double y, double x) => radToDeg(math.atan2(y, x));

/// 角度を0〜360度の範囲に正規化する。
double normalizeDegrees(double deg) => deg % 360;

/// 角度を-180〜180度の範囲に正規化する(平均近点角の計算に使う)。
double normalizeDegrees180(double deg) {
  final d = normalizeDegrees(deg);
  return d > 180 ? d - 360 : d;
}
