/// 古典7天体。仕様書4章の通り、MVPではこの7つのみを扱う。
/// 将来的にカイロン・天王星・海王星・冥王星・セレスを追加する場合はここに足す。
enum CelestialBody {
  sun,
  moon,
  mercury,
  venus,
  mars,
  jupiter,
  saturn,
}

extension CelestialBodyDisplay on CelestialBody {
  /// 日本語表示名
  String get japaneseName {
    switch (this) {
      case CelestialBody.sun:
        return '太陽';
      case CelestialBody.moon:
        return '月';
      case CelestialBody.mercury:
        return '水星';
      case CelestialBody.venus:
        return '金星';
      case CelestialBody.mars:
        return '火星';
      case CelestialBody.jupiter:
        return '木星';
      case CelestialBody.saturn:
        return '土星';
    }
  }

  /// 天体記号(グリフ)。デザインシステムのアイコン表示に使う。
  String get glyph {
    switch (this) {
      case CelestialBody.sun:
        return '☉';
      case CelestialBody.moon:
        return '☽';
      case CelestialBody.mercury:
        return '☿';
      case CelestialBody.venus:
        return '♀';
      case CelestialBody.mars:
        return '♂';
      case CelestialBody.jupiter:
        return '♃';
      case CelestialBody.saturn:
        return '♄';
    }
  }

  /// 公転周期(見かけの周期、年)。頻度計算やトライアングル判定に使う概算値。
  /// 水星・金星は太陽と同じ見かけの周期(約1年)を使う点に注意(仕様書6.2参照)。
  double get orbitalPeriodYears {
    switch (this) {
      case CelestialBody.sun:
        return 1.0;
      case CelestialBody.moon:
        return 27.3 / 365.25;
      case CelestialBody.mercury:
        return 1.0;
      case CelestialBody.venus:
        return 1.0;
      case CelestialBody.mars:
        return 1.88;
      case CelestialBody.jupiter:
        return 11.86;
      case CelestialBody.saturn:
        return 29.5;
    }
  }
}
