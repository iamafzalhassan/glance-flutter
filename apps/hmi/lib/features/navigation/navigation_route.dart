import 'package:glance_maps/glance_maps.dart';

final class RouteLeg {
  final int lengthM;

  final String instruction;

  final Maneuver maneuver;

  const RouteLeg({required this.lengthM, required this.instruction, required this.maneuver});
}

final class NavigationState {
  final double progress;

  final int distanceToTurnM;
  final int remainingM;

  final String nextStreet;

  final DateTime arrival;

  final Maneuver maneuver;

  const NavigationState({required this.progress, required this.distanceToTurnM, required this.remainingM, required this.nextStreet, required this.arrival, required this.maneuver});
}

final class NavigationRoute {
  static const double kmhPerMetrePerSecond = 3.6;

  static const List<NavigationRoute> saved = [
    NavigationRoute(
      destination: 'High Level Road, Nugegoda',
      path: [GeoPoint(6.9271, 79.8448), GeoPoint(6.9115, 79.8500), GeoPoint(6.8930, 79.8565), GeoPoint(6.8870, 79.8680), GeoPoint(6.8790, 79.8770), GeoPoint(6.8720, 79.8890)],
      legs: [
        RouteLeg(instruction: 'Galle Road', lengthM: 1300, maneuver: Maneuver.turnLeft),
        RouteLeg(instruction: 'Duplication Road', lengthM: 1500, maneuver: Maneuver.turnLeft),
        RouteLeg(instruction: 'Bauddhaloka Mawatha', lengthM: 1400, maneuver: Maneuver.turnRight),
        RouteLeg(instruction: 'High Level Road', lengthM: 2000, maneuver: Maneuver.arrive),
      ],
    ),
    NavigationRoute(
      destination: 'Colombo Fort',
      path: [GeoPoint(6.9118, 79.8497), GeoPoint(6.9205, 79.8468), GeoPoint(6.9271, 79.8448), GeoPoint(6.9344, 79.8428)],
      legs: [
        RouteLeg(instruction: 'Galle Road', lengthM: 1600, maneuver: Maneuver.straight),
        RouteLeg(instruction: 'Galle Face Centre Road', lengthM: 900, maneuver: Maneuver.turnRight),
        RouteLeg(instruction: 'Lotus Road', lengthM: 700, maneuver: Maneuver.arrive),
      ],
    ),
    NavigationRoute(
      destination: 'Parliament Road, Rajagiriya',
      path: [GeoPoint(6.9150, 79.8770), GeoPoint(6.9110, 79.8830), GeoPoint(6.9080, 79.8950), GeoPoint(6.9050, 79.9050)],
      legs: [
        RouteLeg(instruction: 'Baseline Road', lengthM: 1500, maneuver: Maneuver.turnRight),
        RouteLeg(instruction: 'Sri Jayawardenepura Mawatha', lengthM: 2200, maneuver: Maneuver.turnLeft),
        RouteLeg(instruction: 'Parliament Road', lengthM: 900, maneuver: Maneuver.arrive),
      ],
    ),
  ];

  final String destination;

  final List<GeoPoint> path;
  final List<RouteLeg> legs;

  final Duration? duration;

  const NavigationRoute({required this.destination, required this.path, required this.legs, this.duration});

  factory NavigationRoute.fromPlan(String destination, RoutePlan plan) {
    final steps = plan.steps;
    return NavigationRoute(
      destination: destination,
      path: plan.path,
      legs: steps.isEmpty
          ? [RouteLeg(instruction: destination, lengthM: plan.distanceM, maneuver: Maneuver.arrive)]
          : [for (var index = 0; index < steps.length; index++) RouteLeg(instruction: steps[index].instruction, lengthM: steps[index].lengthM, maneuver: index + 1 < steps.length ? steps[index + 1].maneuver : Maneuver.arrive)],
      duration: plan.duration,
    );
  }

  int get lengthM => legs.fold(0, (sum, leg) => sum + leg.lengthM);

  NavigationState stateAt(int travelledM, DateTime now, double averageKmh) {
    final total = lengthM;
    final travelled = travelledM.clamp(0, total);
    final remaining = total - travelled;
    var legEnd = 0;
    for (var index = 0; index < legs.length; index++) {
      legEnd += legs[index].lengthM;
      if (travelled < legEnd || index == legs.length - 1) {
        final leg = legs[index];
        final next = index + 1 < legs.length ? legs[index + 1].instruction : destination;
        final duration = this.duration;
        return NavigationState(
          arrival: now.add(duration == null ? Duration(seconds: (remaining / (averageKmh / kmhPerMetrePerSecond)).round()) : duration * (total == 0 ? 0 : remaining / total)),
          distanceToTurnM: legEnd - travelled,
          maneuver: leg.maneuver,
          nextStreet: next,
          progress: total == 0 ? 1 : travelled / total,
          remainingM: remaining,
        );
      }
    }
    throw StateError('Route has no legs');
  }
}
