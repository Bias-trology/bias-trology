import 'photo_source.dart';

/// 推し(人物単位、仕様書3.2)。
/// 1人のOshiが複数のOshiSlot(位相)を持てる。
class Oshi {
  final String id;
  final String name;

  /// 日付部分のみを使用。公開誕生日、必須。
  final DateTime birthDate;

  /// 出生時刻。分かる場合のみ設定(任意)。判明すればアセンダント・ハウスまで解禁される(5.2節)。
  final DateTime? birthTime;

  /// このOshiに紐づく全OshiSlotのデフォルト写真設定。未設定ならプレースホルダー表示。
  final PhotoSource? defaultPhotoSource;

  const Oshi({
    required this.id,
    required this.name,
    required this.birthDate,
    this.birthTime,
    this.defaultPhotoSource,
  });

  /// 出生時刻が判明しているか(「強い分析」機能が使えるかどうかの判定に使う)。
  bool get hasBirthTime => birthTime != null;

  factory Oshi.fromJson(Map<String, dynamic> json) {
    return Oshi(
      id: json['id'] as String,
      name: json['name'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
      birthTime: json['birthTime'] != null
          ? DateTime.parse(json['birthTime'] as String)
          : null,
      defaultPhotoSource: json['defaultPhotoSource'] != null
          ? PhotoSource.fromJson(
              json['defaultPhotoSource'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'birthDate': birthDate.toIso8601String(),
      if (birthTime != null) 'birthTime': birthTime!.toIso8601String(),
      if (defaultPhotoSource != null)
        'defaultPhotoSource': defaultPhotoSource!.toJson(),
    };
  }

  Oshi copyWith({
    String? name,
    DateTime? birthDate,
    DateTime? birthTime,
    PhotoSource? defaultPhotoSource,
  }) {
    return Oshi(
      id: id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      birthTime: birthTime ?? this.birthTime,
      defaultPhotoSource: defaultPhotoSource ?? this.defaultPhotoSource,
    );
  }
}
