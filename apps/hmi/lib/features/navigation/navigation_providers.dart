import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glance_maps/glance_maps.dart';

import '../../core/device/device_location.dart';
import '../../core/providers/map_providers.dart';
import '../../core/providers/telemetry_providers.dart';
import 'arrival_watch.dart';
import 'navigation_route.dart';
import 'off_route_watch.dart';

const double _assumedAverageKmh = 28;

final navigationSessionProvider = NotifierProvider<NavigationSessionNotifier, NavigationSession?>(NavigationSessionNotifier.new);

final navigationProvider = Provider<NavigationState?>((ref) {
  final session = ref.watch(navigationSessionProvider);
  if (session == null) return null;
  final travelledM = session.travelledM(ref.watch(riderLocationProvider).value?.position, ref.watch(telemetryProvider.select((snapshot) => snapshot.odometerM.value)));
  return travelledM == null ? null : session.route.stateAt(travelledM, clock.now(), _assumedAverageKmh);
});

final class NavigationSession {
  final GeoPoint? destination;

  final NavigationRoute route;

  late final RoutePath track = RoutePath(route.path);

  int? startOdometerM;

  NavigationSession({this.startOdometerM, this.destination, required this.route});

  int? travelledM(GeoPoint? position, int? odometerM) {
    if (position != null && track.lengthM > 0) return (track.locate(position).alongM / track.lengthM * route.lengthM).round();
    if (odometerM == null) return null;
    return odometerM - (startOdometerM ??= odometerM);
  }
}

class NavigationSessionNotifier extends Notifier<NavigationSession?> {
  final Stopwatch _clock = Stopwatch()..start();

  bool _routing = false;

  ArrivalWatch _arrival = ArrivalWatch();

  OffRouteWatch _offRoute = OffRouteWatch();

  void start(NavigationRoute route) {
    final odometer = ref.read(telemetryProvider).odometerM.value;
    if (odometer != null) _restart(NavigationSession(route: route, startOdometerM: odometer));
  }

  Future<void> startTo(Place place) async {
    final route = await _route(place.location, place.name);
    _restart(NavigationSession(destination: place.location, route: route, startOdometerM: ref.read(telemetryProvider).odometerM.value));
  }

  void stop() => state = null;

  void _restart(NavigationSession session) {
    _offRoute = OffRouteWatch();
    _begin(session);
  }

  Future<void> _onLocation(DeviceLocation location) async {
    _checkArrival();
    final session = state;
    final destination = session?.destination;
    if (session == null || destination == null || _routing) return;
    if (!_offRoute.shouldReroute(session.track.locate(location.position).offM, _clock.elapsed)) return;
    _routing = true;
    final route = await _route(destination, session.route.destination).then<NavigationRoute?>((route) => route, onError: (Object _) => null);
    _routing = false;
    if (route != null && state == session) _begin(NavigationSession(destination: destination, route: route, startOdometerM: session.startOdometerM));
  }

  void _checkArrival() {
    final session = state;
    final travelledM = session?.travelledM(ref.read(riderLocationProvider).value?.position, ref.read(telemetryProvider).odometerM.value);
    if (session != null && travelledM != null && _arrival.hasArrived(session.route.lengthM - travelledM)) stop();
  }

  Future<NavigationRoute> _route(GeoPoint to, String name) async {
    final client = await ref.read(mapsClientProvider.future);
    final plan = await client?.route(ref.read(riderLocationProvider).value?.position ?? defaultMapCentre, to);
    if (plan == null) throw StateError('No route to $name');
    return NavigationRoute.fromPlan(name, plan);
  }

  void _begin(NavigationSession session) {
    _arrival = ArrivalWatch();
    state = session;
  }

  @override
  NavigationSession? build() {
    ref.listen(riderLocationProvider, (_, next) {
      final location = next.value;
      if (location != null) unawaited(_onLocation(location));
    });
    ref.listen(telemetryProvider.select((snapshot) => snapshot.odometerM.value), (_, _) => _checkArrival());
    return null;
  }
}
