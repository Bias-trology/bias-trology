import 'icon_display_mode.dart';

/// 「推しモード」⇄「星モード」を結ぶ4段階の表示モード。
enum WheelStage {
  /// 最も推しモード側: 均等配置+写真
  evenPhoto,

  /// 実黄経配置+写真
  trueLongitudePhoto,

  /// 実黄経配置+記号
  trueLongitudeGlyph,

  /// 最も星モード側: 実黄経配置+極小記号(円の背景なし)+一覧表
  starMode,
}

extension WheelStageMapping on WheelStage {
  bool get isEvenlySpaced => this == WheelStage.evenPhoto;

  IconDisplayMode get displayMode {
    switch (this) {
      case WheelStage.evenPhoto:
      case WheelStage.trueLongitudePhoto:
        return IconDisplayMode.photo;
      case WheelStage.trueLongitudeGlyph:
      case WheelStage.starMode:
        return IconDisplayMode.glyph;
    }
  }

  bool get isStarMode => this == WheelStage.starMode;

  String get label {
    switch (this) {
      case WheelStage.evenPhoto:
        return '推し';
      case WheelStage.trueLongitudePhoto:
        return '推し寄り';
      case WheelStage.trueLongitudeGlyph:
        return '星寄り';
      case WheelStage.starMode:
        return '星';
    }
  }
}
