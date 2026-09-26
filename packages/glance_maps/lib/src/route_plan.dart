import 'geo_point.dart';
import 'polyline_codec.dart';

enum Maneuver { straight, slightLeft, turnLeft, sharpLeft, uTurnLeft, slightRight, turnRight, sharpRight, uTurnRight, roundaboutLeft, roundaboutRight, forkLeft, forkRight, rampLeft, rampRight, merge, arrive }

final class Place {
  final String address;
  final String id;
  final String name;

  final GeoPoint location;

  const Place({required this.address, required this.id, required this.name, required this.location});

  factory Place.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>;
    return Place(
      address: json['formattedAddress'] as String? ?? '',
      id: json['id'] as String,
      name: (json['displayName'] as Map<String, dynamic>?)?['text'] as String? ?? '',
      location: GeoPoint((location['latitude'] as num).toDouble(), (location['longitude'] as num).toDouble()),
    );
  }
}

final class RouteStep {
  final int lengthM;

  final String instruction;

  final Maneuver maneuver;

  const RouteStep({required this.lengthM, required this.instruction, required this.maneuver});

  factory RouteStep.fromJson(Map<String, dynamic> json) {
    final instruction = json['navigationInstruction'] as Map<String, dynamic>?;
    return RouteStep(lengthM: json['distanceMeters'] as int? ?? 0, instruction: instruction?['instructions'] as String? ?? '', maneuver: RoutePlan.maneuvers[instruction?['maneuver']] ?? Maneuver.straight);
  }
}

final class RoutePlan {
  static const Map<String, Maneuver> maneuvers = {
    'FORK_LEFT': Maneuver.forkLeft,
    'FORK_RIGHT': Maneuver.forkRight,
    'MERGE': Maneuver.merge,
    'RAMP_LEFT': Maneuver.rampLeft,
    'RAMP_RIGHT': Maneuver.rampRight,
    'ROUNDABOUT_LEFT': Maneuver.roundaboutLeft,
    'ROUNDABOUT_RIGHT': Maneuver.roundaboutRight,
    'TURN_LEFT': Maneuver.turnLeft,
    'TURN_RIGHT': Maneuver.turnRight,
    'TURN_SHARP_LEFT': Maneuver.sharpLeft,
    'TURN_SHARP_RIGHT': Maneuver.sharpRight,
    'TURN_SLIGHT_LEFT': Maneuver.slightLeft,
    'TURN_SLIGHT_RIGHT': Maneuver.slightRight,
    'UTURN_LEFT': Maneuver.uTurnLeft,
    'UTURN_RIGHT': Maneuver.uTurnRight,
  };

  final int distanceM;

  final List<GeoPoint> path;
  final List<RouteStep> steps;

  final Duration duration;

  const RoutePlan({required this.distanceM, required this.path, required this.steps, required this.duration});

  factory RoutePlan.fromJson(Map<String, dynamic> json) => RoutePlan(
    distanceM: json['distanceMeters'] as int? ?? 0,
    path: PolylineCodec.decode((json['polyline'] as Map<String, dynamic>)['encodedPolyline'] as String),
    steps: [
      for (final leg in json['legs'] as List? ?? const [])
        for (final step in (leg as Map<String, dynamic>)['steps'] as List? ?? const []) RouteStep.fromJson(step as Map<String, dynamic>),
    ],
    duration: Duration(seconds: int.tryParse((json['duration'] as String? ?? '0s').replaceAll('s', '')) ?? 0),
  );
}
