import 'dart:math';

final class GeoPoint {
  static const double earthRadiusM = 6371000;

  final double latitude;
  final double longitude;

  const GeoPoint(this.latitude, this.longitude);

  double bearingTo(GeoPoint other) {
    final fromLatitude = _radians(latitude);
    final toLatitude = _radians(other.latitude);
    final deltaLongitude = _radians(other.longitude - longitude);
    final y = sin(deltaLongitude) * cos(toLatitude);
    final x = cos(fromLatitude) * sin(toLatitude) - sin(fromLatitude) * cos(toLatitude) * cos(deltaLongitude);
    return (atan2(y, x) * 180 / pi + 360) % 360;
  }

  double distanceTo(GeoPoint other) {
    final deltaLatitude = _radians(other.latitude - latitude);
    final deltaLongitude = _radians(other.longitude - longitude);
    final a = pow(sin(deltaLatitude / 2), 2) + cos(_radians(latitude)) * cos(_radians(other.latitude)) * pow(sin(deltaLongitude / 2), 2);
    return earthRadiusM * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  GeoPoint lerp(GeoPoint other, double t) => GeoPoint(latitude + (other.latitude - latitude) * t, longitude + (other.longitude - longitude) * t);

  double _radians(double degrees) => degrees * pi / 180;

  @override
  bool operator ==(Object other) => other is GeoPoint && other.latitude == latitude && other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);
}
