import '../models/aspect_type.dart';
import '../models/celestial_body.dart';
import 'aspect_calculator.dart';
import 'planetary_positions.dart';

enum FeatureTier { regular, notable, special }

/// その日の「一推し」判定結果。
class DailyFeature {
  final CelestialBody featuredBody;
  final CelestialBody partnerBody;
  final AspectType aspectType;
  final double orbDeviation;
  final FeatureTier tier;

  const DailyFeature({
    required this.featuredBody,
    required this.partnerBody,
    required this.aspectType,
    required this.orbDeviation,
    required this.tier,
  });
}

/// 7天体の全21ペアの中から、その日もっともぴったり合っているアスペクトを1つ選ぶ。
/// orbを広め(8度)に取っているため、ほぼ毎日何かしら見つかる設計。
DailyFeature computeDailyFeature(DateTime utcDateTime) {
  final positions = computeGeocentricLongitudes(utcDateTime);
  final bodies = CelestialBody.values;

  AspectHit? bestHit;
  CelestialBody? bestA;
  CelestialBody? bestB;

  for (var i = 0; i < bodies.length; i++) {
    for (var j = i + 1; j < bodies.length; j++) {
      final hit = findAspect(
        positions[bodies[i]]!,
        positions[bodies[j]]!,
        orb: 8.0,
      );
      if (hit != null &&
          (bestHit == null || hit.orbDeviation < bestHit.orbDeviation)) {
        bestHit = hit;
        bestA = bodies[i];
        bestB = bodies[j];
      }
    }
  }

  // 105通りの候補(21ペア×5アスペクト)に対してorb8度なので、
  // 見つからないことは理論上ほぼないが、念のためフォールバックを用意
  bestHit ??= const AspectHit(type: AspectType.conjunction, orbDeviation: 999);
  bestA ??= CelestialBody.sun;
  bestB ??= CelestialBody.moon;

  // 軌道周期が長い方(=より珍しい方)を主役にする
  final featured =
      bestA.orbitalPeriodYears >= bestB.orbitalPeriodYears ? bestA : bestB;
  final partner = featured == bestA ? bestB : bestA;

  return DailyFeature(
    featuredBody: featured,
    partnerBody: partner,
    aspectType: bestHit.type,
    orbDeviation: bestHit.orbDeviation,
    tier: _tierFor(bestHit.orbDeviation, bestHit.type),
  );
}

FeatureTier _tierFor(double deviation, AspectType type) {
  final isMajor =
      type == AspectType.conjunction || type == AspectType.opposition;
  if (isMajor && deviation <= 0.75) return FeatureTier.special;
  if (deviation <= 1.5) return FeatureTier.notable;
  return FeatureTier.regular;
}
