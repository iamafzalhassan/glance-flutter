import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glance/core/providers/device_providers.dart';
import 'package:glance/core/providers/telemetry_providers.dart';
import 'package:glance/features/trip_summary/ride_summary.dart';
import 'package:glance_protocol/glance_protocol.dart';
import 'package:glance_telemetry/glance_telemetry.dart';

import '../../helpers/fake_telemetry.dart';

void main() {
  test('summarises the distance between ignition on and ignition off', () {
    final telemetry = FakeTelemetryNotifier(snapshotWith(linkUp: false));
    final container = ProviderContainer(overrides: [telemetryProvider.overrideWith(() => telemetry)]);
    addTearDown(container.dispose);
    container.listen(rideSummaryProvider, (_, _) {});
    telemetry.emit(
      snapshotWith(
        flags: const {TelemetryFlag.ignition},
        odometerM: 100000,
        speedKmh: const Reading(freshness: Freshness.live, value: 20),
      ),
    );
    container.read(ignitionProvider);
    telemetry.emit(
      snapshotWith(
        flags: const {TelemetryFlag.ignition},
        odometerM: 102000,
        speedKmh: const Reading(freshness: Freshness.live, value: 64),
      ),
    );
    container.read(ignitionProvider);
    telemetry.emit(snapshotWith(odometerM: 104500, speedKmh: const Reading(freshness: Freshness.live, value: 0)));
    container.read(ignitionProvider);
    final summary = container.read(rideSummaryProvider);
    expect(summary?.distanceM, 4500);
    expect(summary?.maxKmh, 64);
  });
}
