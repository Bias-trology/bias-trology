import '../models/oshi.dart';
import '../models/user.dart';
import 'timezone_conversion.dart';

/// Userの出生日時(ローカル)を、正しいUTCの一瞬に変換する。
/// User.birthTimeZoneIdは必須項目なので、常に計算可能。
DateTime userBirthInstantUtc(User user) {
  final wallClock = DateTime(
    user.birthDate.year,
    user.birthDate.month,
    user.birthDate.day,
    user.birthTime.hour,
    user.birthTime.minute,
  );
  return convertLocalToUtc(
    localWallClockTime: wallClock,
    ianaTimeZoneId: user.birthTimeZoneId,
  );
}

/// Oshiの出生日時をUTCに変換する。
/// 出生時刻・出生地・タイムゾーンが全て揃っている場合のみ計算できる
/// (Oshi.hasFullBirthDataがfalseの場合はnullを返す)。
///
/// 時刻が不明なOshi(基本ケース)については、太陽〜土星の位置は日付だけで
/// 十分な精度が出るため(仕様書5.1節)、呼び出し側でその日の正午UTC等を
/// 代替値として使うことを想定する。この関数はあくまで「正確な時刻がある場合」
/// の変換のみを担う。
DateTime? oshiBirthInstantUtc(Oshi oshi) {
  if (!oshi.hasFullBirthData) return null;

  final wallClock = DateTime(
    oshi.birthDate.year,
    oshi.birthDate.month,
    oshi.birthDate.day,
    oshi.birthTime!.hour,
    oshi.birthTime!.minute,
  );
  return convertLocalToUtc(
    localWallClockTime: wallClock,
    ianaTimeZoneId: oshi.birthTimeZoneId!,
  );
}

/// Oshiの出生時刻が不明な場合の代替UTC日時(その日の正午UTCとする)。
/// 太陽〜土星の位置は日付単位でほぼ確定するため、正午を使うことによる
/// 誤差は実用上無視できる(月のみ多少の誤差が出うる、仕様書5.1節参照)。
DateTime oshiBirthInstantUtcOrNoon(Oshi oshi) {
  return oshiBirthInstantUtc(oshi) ??
      DateTime.utc(
        oshi.birthDate.year,
        oshi.birthDate.month,
        oshi.birthDate.day,
        12,
      );
}
