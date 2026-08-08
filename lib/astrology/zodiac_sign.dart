/// 西洋占星術の12星座(サイン)。
enum ZodiacSign {
  aries,
  taurus,
  gemini,
  cancer,
  leo,
  virgo,
  libra,
  scorpio,
  sagittarius,
  capricorn,
  aquarius,
  pisces,
}

extension ZodiacSignDisplay on ZodiacSign {
  String get japaneseName {
    const names = [
      '牡羊座',
      '牡牛座',
      '双子座',
      '蟹座',
      '獅子座',
      '乙女座',
      '天秤座',
      '蠍座',
      '射手座',
      '山羊座',
      '水瓶座',
      '魚座',
    ];
    return names[index];
  }
}

/// 黄経(0〜360度)を星座に変換する。1サインは30度。
ZodiacSign zodiacSignFromLongitude(double eclipticLongitudeDeg) {
  final normalized = eclipticLongitudeDeg % 360;
  final index = (normalized / 30).floor() % 12;
  return ZodiacSign.values[index];
}
