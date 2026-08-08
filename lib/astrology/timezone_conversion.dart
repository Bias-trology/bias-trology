import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// アプリ起動時に一度だけ呼び出す(main()の最初、runApp()より前)。
/// IANA時間帯データベースをメモリ上に読み込む。
void initializeTimeZoneDatabase() {
  tzdata.initializeTimeZones();
}

/// あるタイムゾーンでの「壁時計時刻」(例: 1998年5月3日 14時30分、東京)を、
/// 正しいUTCの一瞬に変換する。
///
/// 出生地の歴史的な夏時間(サマータイム)ルールなど、IANAデータベースに
/// 記録されている範囲の時差変更は自動的に反映される。
///
/// [localWallClockTime] の年月日時分秒のみを使う(タイムゾーン情報は無視される)。
/// [ianaTimeZoneId] は 'Asia/Tokyo' のようなIANA形式のタイムゾーンID。
DateTime convertLocalToUtc({
  required DateTime localWallClockTime,
  required String ianaTimeZoneId,
}) {
  final location = tz.getLocation(ianaTimeZoneId);
  final tzDateTime = tz.TZDateTime(
    location,
    localWallClockTime.year,
    localWallClockTime.month,
    localWallClockTime.day,
    localWallClockTime.hour,
    localWallClockTime.minute,
    localWallClockTime.second,
  );
  return tzDateTime.toUtc();
}

/// 指定したタイムゾーンIDが存在するかどうかを確認する(入力バリデーション用)。
bool isValidTimeZoneId(String ianaTimeZoneId) {
  try {
    tz.getLocation(ianaTimeZoneId);
    return true;
  } on Exception {
    return false;
  }
}
