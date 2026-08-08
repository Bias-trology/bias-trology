/// DateTime(UTC想定)からユリウス日(JD)を求める。
/// 標準的な天文計算式(Meeus方式)。グレゴリオ暦(1582年10月15日以降)を前提とする。
///
/// 重要: 引数のDateTimeはUTCで渡すこと。ユーザーの出生時刻はローカルタイムゾーンで
/// 入力されるため、呼び出し側でタイムゾーン変換を行ってから渡す必要がある。
/// (タイムゾーン変換は歴史的なタイムゾーンデータベースが必要になるため、
/// 別途 `timezone` パッケージ等の導入を推奨。現時点ではTODOとする。)
double toJulianDay(DateTime utc) {
  int year = utc.year;
  int month = utc.month;
  final double day = utc.day +
      utc.hour / 24.0 +
      utc.minute / 1440.0 +
      utc.second / 86400.0;

  if (month <= 2) {
    year -= 1;
    month += 12;
  }

  final int a = (year / 100).floor();
  final int b = 2 - a + (a / 4).floor();

  final double jd = (365.25 * (year + 4716)).floorToDouble() +
      (30.6001 * (month + 1)).floorToDouble() +
      day +
      b -
      1524.5;

  return jd;
}

/// J2000.0(JD 2451545.0)からの経過世紀数(T)。軌道要素の時間変化計算に使う。
double centuriesSinceJ2000(double julianDay) {
  return (julianDay - 2451545.0) / 36525.0;
}
