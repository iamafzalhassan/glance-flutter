import 'dart:math';

import 'geo_point.dart';

final class RoutePath {
  final List<double> _cumulativeM;

  final List<GeoPoint> points;

  RoutePath(this.points) : _cumulativeM = _cumulate(points);

  double get lengthM => _cumulativeM.isEmpty ? 0 : _cumulativeM.last;

  ({List<GeoPoint> ahead, double bearing, GeoPoint position}) at(double progress) {
    if (points.length < 2) return (ahead: points, bearing: 0, position: points.isEmpty ? const GeoPoint(0, 0) : points.first);
    final travelled = lengthM * progress.clamp(0, 1);
    var segment = 1;
    while (segment < points.length - 1 && _cumulativeM[segment] < travelled) {
      segment++;
    }
    final start = points[segment - 1];
    final end = points[segment];
    final span = _cumulativeM[segment] - _cumulativeM[segment - 1];
    final position = start.lerp(end, span == 0 ? 0 : (travelled - _cumulativeM[segment - 1]) / span);
    return (ahead: [position, ...points.skip(segment)], bearing: start.bearingTo(end), position: position);
  }

  ({double alongM, double offM}) locate(GeoPoint point) {
    if (points.length < 2) return (alongM: 0, offM: points.isEmpty ? 0 : point.distanceTo(points.first));
    var best = (alongM: 0.0, offM: double.infinity);
    for (var segment = 1; segment < points.length; segment++) {
      final start = points[segment - 1];
      final end = points[segment];
      final scale = cos(start.latitude * pi / 180);
      final dx = (end.longitude - start.longitude) * scale;
      final dy = end.latitude - start.latitude;
      final lengthSquared = dx * dx + dy * dy;
      final t = lengthSquared == 0 ? 0.0 : (((point.longitude - start.longitude) * scale * dx + (point.latitude - start.latitude) * dy) / lengthSquared).clamp(0.0, 1.0);
      final offM = point.distanceTo(start.lerp(end, t));
      if (offM < best.offM) best = (alongM: _cumulativeM[segment - 1] + (_cumulativeM[segment] - _cumulativeM[segment - 1]) * t, offM: offM);
    }
    return best;
  }

  static List<double> _cumulate(List<GeoPoint> points) {
    final cumulative = <double>[];
    for (var index = 0; index < points.length; index++) {
      cumulative.add(index == 0 ? 0 : cumulative[index - 1] + points[index - 1].distanceTo(points[index]));
    }
    return cumulative;
  }
}
