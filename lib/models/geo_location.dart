/// 緯度経度(+任意の地名)を表す値オブジェクト。
/// 出生地(User.birthPlace)、現在地(User.currentLocation)の両方で使う。
class GeoLocation {
  final double latitude;
  final double longitude;
  final String? placeName;

  const GeoLocation({
    required this.latitude,
    required this.longitude,
    this.placeName,
  });

  factory GeoLocation.fromJson(Map<String, dynamic> json) {
    return GeoLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      placeName: json['placeName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      if (placeName != null) 'placeName': placeName,
    };
  }

  GeoLocation copyWith({
    double? latitude,
    double? longitude,
    String? placeName,
  }) {
    return GeoLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      placeName: placeName ?? this.placeName,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GeoLocation &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() =>
      'GeoLocation(lat: $latitude, lng: $longitude, name: $placeName)';
}
