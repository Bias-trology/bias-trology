import '../models/aspect_type.dart';

/// アスペクト判定結果。
class AspectHit {
  final AspectType type;

  /// 理論上の角度からのズレ(度)。0に近いほど「ぴったり」。
  final double orbDeviation;

  const AspectHit({required this.type, required this.orbDeviation});

  @override
  String toString() =>
      '${type.japaneseName}(ずれ ${orbDeviation.toStringAsFixed(2)}度)';
}

/// 2つの黄経の間の角距離(0〜180度)を求める。
double angularSeparation(double lonA, double lonB) {
  double diff = (lonA - lonB) % 360;
  if (diff < 0) diff += 360;
  return diff > 180 ? 360 - diff : diff;
}

/// 2天体の黄経からアスペクトを判定する。
/// [orb] は許容誤差(度)。天体の組み合わせによって呼び出し側で変えてよい
/// (仕様書6.1・6.4節: 太陽は約8度、月は狭め、木星・土星のトライアングルは合・衝のみ等)。
/// 該当するアスペクトがなければnullを返す。
AspectHit? findAspect(
  double lonA,
  double lonB, {
  double orb = 6.0,
  List<AspectType> candidates = AspectType.values,
}) {
  final separation = angularSeparation(lonA, lonB);

  AspectHit? best;
  for (final type in candidates) {
    final deviation = (separation - type.degrees).abs();
    if (deviation <= orb) {
      if (best == null || deviation < best.orbDeviation) {
        best = AspectHit(type: type, orbDeviation: deviation);
      }
    }
  }
  return best;
}
