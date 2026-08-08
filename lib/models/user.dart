import 'geo_location.dart';

/// アプリのユーザー本人(仕様書3.1)。
/// 出生時刻・出生地はハウス・アセンダント算出に必須のため、両方必須項目として扱う。
class User {
  final String id;
  final String name;

  /// 日付部分のみを使用(年・月・日)。
  final DateTime birthDate;

  /// 時刻部分のみを使用(時・分)。日付部分は無視してよい。
  final DateTime birthTime;

  final GeoLocation birthPlace;

  /// 出生時刻が記録されているタイムゾーン(IANA形式、例: 'Asia/Tokyo')。
  /// birthTimeを正しいUTCの一瞬に変換するために必須。
  final String birthTimeZoneId;

  /// 「今」のホロスコープ(5.3節)算出用。未設定なら出生地で代替する。
  final GeoLocation? currentLocation;

  const User({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.birthTime,
    required this.birthPlace,
    required this.birthTimeZoneId,
    this.currentLocation,
  });

  /// 現在地が未設定の場合は出生地を代替として返す(5.3節の代替方針)。
  GeoLocation get effectiveCurrentLocation => currentLocation ?? birthPlace;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
      birthTime: DateTime.parse(json['birthTime'] as String),
      birthPlace:
          GeoLocation.fromJson(json['birthPlace'] as Map<String, dynamic>),
      birthTimeZoneId: json['birthTimeZoneId'] as String,
      currentLocation: json['currentLocation'] != null
          ? GeoLocation.fromJson(
              json['currentLocation'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'birthDate': birthDate.toIso8601String(),
      'birthTime': birthTime.toIso8601String(),
      'birthPlace': birthPlace.toJson(),
      'birthTimeZoneId': birthTimeZoneId,
      if (currentLocation != null) 'currentLocation': currentLocation!.toJson(),
    };
  }

  User copyWith({
    String? name,
    DateTime? birthDate,
    DateTime? birthTime,
    GeoLocation? birthPlace,
    String? birthTimeZoneId,
    GeoLocation? currentLocation,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      birthTime: birthTime ?? this.birthTime,
      birthPlace: birthPlace ?? this.birthPlace,
      birthTimeZoneId: birthTimeZoneId ?? this.birthTimeZoneId,
      currentLocation: currentLocation ?? this.currentLocation,
    );
  }
}
