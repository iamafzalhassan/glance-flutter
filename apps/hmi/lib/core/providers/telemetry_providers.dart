import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glance_telemetry/glance_telemetry.dart';

import '../config/app_config.dart';

const double _simulatedLowFuelPercent = 15;

final appConfigProvider = Provider<AppConfig>((ref) => AppConfig.fromEnvironment());

final simulatorProvider = Provider<SimulatorSource>((ref) {
  final simulator = SimulatorSource(bike: SimulatedBike(lowFuelPercent: _simulatedLowFuelPercent));
  ref.onDispose(simulator.close);
  return simulator;
});

final telemetrySourceProvider = Provider<TelemetrySource>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.source != TelemetrySourceKind.websocket) return ref.watch(simulatorProvider);
  final source = WebSocketSource(config.webSocketUri);
  ref.onDispose(source.close);
  return source;
});

final telemetryHubProvider = Provider<TelemetryHub>((ref) {
  final hub = TelemetryHub()..attach(ref.watch(telemetrySourceProvider));
  ref.onDispose(hub.dispose);
  return hub;
});

final telemetryProvider = NotifierProvider<TelemetryNotifier, TelemetrySnapshot>(TelemetryNotifier.new);

class TelemetryNotifier extends Notifier<TelemetrySnapshot> {
  @override
  TelemetrySnapshot build() {
    final hub = ref.watch(telemetryHubProvider);
    final subscription = hub.snapshots.listen((snapshot) => state = snapshot);
    ref.onDispose(subscription.cancel);
    return hub.current;
  }
}
