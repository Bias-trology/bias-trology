/// 写真設定のモード(仕様書3.5)。
enum PhotoSourceMode {
  fixedPhoto, // 固定写真(1枚指定)
  folder, // フォルダ参照(端末/クラウド、自動スライドショー)
}

/// Oshi(デフォルト)またはOshiSlot(個別上書き)に紐づく写真設定。
class PhotoSource {
  final PhotoSourceMode mode;

  /// fixedPhotoの場合は画像1枚のパス、folderの場合はフォルダのパス。
  final String path;

  const PhotoSource({
    required this.mode,
    required this.path,
  });

  factory PhotoSource.fixed(String imagePath) {
    return PhotoSource(mode: PhotoSourceMode.fixedPhoto, path: imagePath);
  }

  factory PhotoSource.folder(String folderPath) {
    return PhotoSource(mode: PhotoSourceMode.folder, path: folderPath);
  }

  factory PhotoSource.fromJson(Map<String, dynamic> json) {
    return PhotoSource(
      mode: PhotoSourceMode.values.byName(json['mode'] as String),
      path: json['path'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mode': mode.name,
      'path': path,
    };
  }

  @override
  String toString() => 'PhotoSource(mode: $mode, path: $path)';
}
