import 'celestial_body.dart';

/// User × OshiSlotの組み合わせごとに算出される、担当天体の出生位置の中間点(仕様書3.4)。
/// OshiSlot登録時に1回計算し、以後キャッシュする(担当天体変更時のみ再計算)。
class CompositePoint {
  final String userId;
  final String oshiSlotId;
  final CelestialBody celestialBody;

  /// 黄経(0〜360度)の中間点。
  final double degree;

  final DateTime calculatedAt;

  const CompositePoint({
    required this.userId,
    required this.oshiSlotId,
    required this.celestialBody,
    required this.degree,
    required this.calculatedAt,
  });

  factory CompositePoint.fromJson(Map<String, dynamic> json) {
    return CompositePoint(
      userId: json['userId'] as String,
      oshiSlotId: json['oshiSlotId'] as String,
      celestialBody: CelestialBody.values.byName(json['celestialBody'] as String),
      degree: (json['degree'] as num).toDouble(),
      calculatedAt: DateTime.parse(json['calculatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'oshiSlotId': oshiSlotId,
      'celestialBody': celestialBody.name,
      'degree': degree,
      'calculatedAt': calculatedAt.toIso8601String(),
    };
  }
}
