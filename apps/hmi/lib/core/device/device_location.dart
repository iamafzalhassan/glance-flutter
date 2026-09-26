import 'package:glance_maps/glance_maps.dart';

final class DeviceLocation {
  final double? bearing;

  final GeoPoint position;

  const DeviceLocation({this.bearing, required this.position});

  factory DeviceLocation.fromMap(Map<Object?, Object?> map) => DeviceLocation(bearing: (map['bearing'] as num?)?.toDouble(), position: GeoPoint((map['latitude'] as num).toDouble(), (map['longitude'] as num).toDouble()));
}
