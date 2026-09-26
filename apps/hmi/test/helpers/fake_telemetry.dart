import 'package:glance/core/providers/telemetry_providers.dart';
import 'package:glance_protocol/glance_protocol.dart';
import 'package:glance_telemetry/glance_telemetry.dart';

TelemetrySnapshot snapshotWith({
  bool linkUp = true,
  int odometerM = 18420000,
  Set<TelemetryFlag> flags = const {},
  Reading<double> fuelPercent = const Reading(freshness: Freshness.live, value: 62),
  Reading<double> speedKmh = const Reading(freshness: Freshness.live, value: 42.4),
}) => TelemetrySnapshot(
  bikeMv: const Reading.missing(),
  flags: Reading(freshness: linkUp ? Freshness.live : Freshness.stale, value: TelemetryFlag.pack(flags)),
  fuelPercent: fuelPercent,
  fuelRawMv: const Reading.missing(),
  linkUp: linkUp,
  odometerM: Reading(freshness: Freshness.live, value: odometerM),
  ridingLocked: (speedKmh.value ?? 0) > TelemetryPolicy.standard.ridingLockAboveKmh,
  speedKmh: speedKmh,
  stats: LinkStats.empty,
  tripAM: const Reading(freshness: Freshness.live, value: 36400),
  tripBM: const Reading(freshness: Freshness.live, value: 1200),
);

class FakeTelemetryNotifier extends TelemetryNotifier {
  final TelemetrySnapshot initial;

  FakeTelemetryNotifier(this.initial);

  void emit(TelemetrySnapshot snapshot) => state = snapshot;

  @override
  TelemetrySnapshot build() => initial;
}
