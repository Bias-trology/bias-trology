import 'math_utils.dart';

/// 月の地心黄経の簡易計算(主要項のみ、精度おおよそ0.3〜0.5度程度)。
/// 出典: Jean Meeus "Astronomical Algorithms" の低精度近似式(主要6項)を単純化したもの。
/// 月はサインを約2.5日で移動するため、サイン境界付近の生年月日は多少の誤差が出うる
/// (仕様書5.1節で言及済みの既知の制約)。
double computeMoonEclipticLongitude(double t) {
  // 平均黄経
  final lPrime = normalizeDegrees(
      218.3164477 + 481267.88123421 * t - 0.0015786 * t * t);
  // 平均離角(太陽からの)
  final d =
      normalizeDegrees(297.8501921 + 445267.1114034 * t - 0.0018819 * t * t);
  // 太陽の平均近点角
  final m = normalizeDegrees(357.5291092 + 35999.0502909 * t - 0.0001536 * t * t);
  // 月の平均近点角
  final mPrime =
      normalizeDegrees(134.9633964 + 477198.8675055 * t + 0.0087414 * t * t);
  // 月の緯度引数
  final f =
      normalizeDegrees(93.2720950 + 483202.0175233 * t - 0.0036539 * t * t);

  // 主要な周期項による黄経補正(度)。フルセットは約60項あるが、
  // 振幅上位6項のみでも実用上おおよそ0.3〜0.5度程度の精度が得られる。
  final correction = 6.288774 * sinDeg(mPrime) +
      1.274027 * sinDeg(2 * d - mPrime) +
      0.658314 * sinDeg(2 * d) +
      0.213618 * sinDeg(2 * mPrime) -
      0.185116 * sinDeg(m) -
      0.114332 * sinDeg(2 * f);

  return normalizeDegrees(lPrime + correction);
}
