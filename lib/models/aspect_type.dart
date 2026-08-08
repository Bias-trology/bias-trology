/// 使用する5種類のアスペクト(仕様書6.1)。
enum AspectType {
  conjunction, // 合 0°
  sextile, // 60°
  square, // 90°
  trine, // 120°
  opposition, // 衝 180°
}

extension AspectTypeDisplay on AspectType {
  /// 対応する角度
  double get degrees {
    switch (this) {
      case AspectType.conjunction:
        return 0;
      case AspectType.sextile:
        return 60;
      case AspectType.square:
        return 90;
      case AspectType.trine:
        return 120;
      case AspectType.opposition:
        return 180;
    }
  }

  String get japaneseName {
    switch (this) {
      case AspectType.conjunction:
        return '合';
      case AspectType.sextile:
        return 'セクスタイル';
      case AspectType.square:
        return 'スクエア';
      case AspectType.trine:
        return 'トライン';
      case AspectType.opposition:
        return '衝';
    }
  }

  /// 合・衝は仕様書6.1の通り「豪華演出」の対象
  bool get isMajorEvent =>
      this == AspectType.conjunction || this == AspectType.opposition;
}
