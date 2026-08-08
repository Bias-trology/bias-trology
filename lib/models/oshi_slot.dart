import 'celestial_body.dart';
import 'oshi.dart';
import 'photo_source.dart';

/// 推し天体スロット = 位相(仕様書3.3、8章)。
/// 同一Oshiが複数の担当天体を持つ場合、それぞれが「同一人物の異なる顕現」を表す。
class OshiSlot {
  final String id;
  final String oshiId;
  final CelestialBody celestialBody;

  /// このスロット限定の写真設定。未設定の場合はOshi.defaultPhotoSourceを継承する。
  /// 実際にどちらを使うかはresolvePhotoSource()で解決する。
  final PhotoSource? photoSourceOverride;

  /// 口調・性格パラメータ(位相ごとのセリフ生成に使うキー)。
  /// MVPでは天体ごとの既定トーン("鷹揚","寡黙"等)を指すキー文字列として扱う。
  final String? toneProfile;

  const OshiSlot({
    required this.id,
    required this.oshiId,
    required this.celestialBody,
    this.photoSourceOverride,
    this.toneProfile,
  });

  factory OshiSlot.fromJson(Map<String, dynamic> json) {
    return OshiSlot(
      id: json['id'] as String,
      oshiId: json['oshiId'] as String,
      celestialBody: CelestialBody.values.byName(json['celestialBody'] as String),
      photoSourceOverride: json['photoSourceOverride'] != null
          ? PhotoSource.fromJson(
              json['photoSourceOverride'] as Map<String, dynamic>)
          : null,
      toneProfile: json['toneProfile'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'oshiId': oshiId,
      'celestialBody': celestialBody.name,
      if (photoSourceOverride != null)
        'photoSourceOverride': photoSourceOverride!.toJson(),
      if (toneProfile != null) 'toneProfile': toneProfile,
    };
  }

  OshiSlot copyWith({
    PhotoSource? photoSourceOverride,
    String? toneProfile,
  }) {
    return OshiSlot(
      id: id,
      oshiId: oshiId,
      celestialBody: celestialBody,
      photoSourceOverride: photoSourceOverride ?? this.photoSourceOverride,
      toneProfile: toneProfile ?? this.toneProfile,
    );
  }
}

/// 写真設定の解決順序(仕様書3.5): スロット上書き → Oshiのデフォルト → null(プレースホルダー)。
PhotoSource? resolvePhotoSource(OshiSlot slot, Oshi oshi) {
  return slot.photoSourceOverride ?? oshi.defaultPhotoSource;
}
