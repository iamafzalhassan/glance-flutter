import 'package:flutter/widgets.dart';

import 'geo_point.dart';
import 'google_route_map_view.dart';
import 'map_palette.dart';
import 'route_path.dart';
import 'schematic_map_view.dart';

class GlanceMapView extends StatelessWidget {
  const GlanceMapView({super.key, required this.google, required this.night, this.heading = 0, required this.progress, required this.path, required this.routeColor, required this.centre, this.rider});

  final bool google;
  final bool night;

  final double heading;
  final double progress;

  final List<GeoPoint> path;

  final Color routeColor;

  final GeoPoint centre;

  final GeoPoint? rider;

  @override
  Widget build(BuildContext context) {
    if (!google) return SchematicMapView(palette: night ? MapPalette.night : MapPalette.day, progress: progress, routeColor: routeColor);
    final route = path.length > 1 ? RoutePath(path).at(progress) : null;
    return GoogleRouteMapView(ahead: route?.ahead ?? const [], bearing: route?.bearing ?? heading, centre: centre, night: night, rider: route?.position ?? rider, routeColor: routeColor);
  }
}
