import 'dart:convert';

import 'package:http/http.dart' as http;

import 'geo_point.dart';
import 'route_plan.dart';

final class MapsCredentials {
  final String apiKey;

  final Map<String, String> headers;

  const MapsCredentials({required this.apiKey, this.headers = const {}});
}

final class GoogleMapsClient {
  static const double biasRadiusM = 30000;

  static const int maxPlaces = 8;

  static const String placesFields = 'places.id,places.displayName,places.formattedAddress,places.location';
  static const String placesUrl = 'https://places.googleapis.com/v1/places:searchText';
  static const String routeFields = 'routes.distanceMeters,routes.duration,routes.polyline.encodedPolyline,routes.legs.steps.distanceMeters,routes.legs.steps.navigationInstruction';
  static const String routesUrl = 'https://routes.googleapis.com/directions/v2:computeRoutes';

  static const List<String> travelModes = ['TWO_WHEELER', 'DRIVE'];

  static const Duration timeout = Duration(seconds: 10);

  final http.Client _http;

  final MapsCredentials credentials;

  GoogleMapsClient(this.credentials, {http.Client? client}) : _http = client ?? http.Client();

  Future<RoutePlan?> route(GeoPoint from, GeoPoint to) async {
    for (final mode in travelModes) {
      try {
        final json = await _post(routesUrl, routeFields, {'destination': _waypoint(to), 'languageCode': 'en', 'origin': _waypoint(from), 'travelMode': mode});
        final routes = json['routes'] as List?;
        if (routes != null && routes.isNotEmpty) return RoutePlan.fromJson(routes.first as Map<String, dynamic>);
      } on MapsException {
        if (mode == travelModes.last) rethrow;
      }
    }
    return null;
  }

  Future<List<Place>> searchPlaces(String query, GeoPoint near) async {
    final json = await _post(placesUrl, placesFields, {
      'locationBias': {
        'circle': {'center': _latLng(near), 'radius': biasRadiusM},
      },
      'pageSize': maxPlaces,
      'textQuery': query,
    });
    return [for (final place in json['places'] as List? ?? const []) Place.fromJson(place as Map<String, dynamic>)];
  }

  void close() => _http.close();

  Future<Map<String, dynamic>> _post(String url, String fields, Map<String, Object> body) async {
    final response = await _http.post(Uri.parse(url), body: jsonEncode(body), headers: {'Content-Type': 'application/json', 'X-Goog-Api-Key': credentials.apiKey, 'X-Goog-FieldMask': fields, ...credentials.headers}).timeout(timeout);
    if (response.statusCode != 200) throw MapsException(response.statusCode);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Map<String, Object> _waypoint(GeoPoint point) => {
    'location': {'latLng': _latLng(point)},
  };

  Map<String, double> _latLng(GeoPoint point) => {'latitude': point.latitude, 'longitude': point.longitude};
}

final class MapsException implements Exception {
  final int statusCode;

  const MapsException(this.statusCode);

  @override
  String toString() => 'MapsException($statusCode)';
}
