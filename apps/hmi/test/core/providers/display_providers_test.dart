import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glance/core/providers/display_providers.dart';
import 'package:glance/core/providers/telemetry_providers.dart';
import 'package:glance_telemetry/glance_telemetry.dart';

import '../../helpers/fake_telemetry.dart';

void main() {
  late FakeTelemetryNotifier telemetry;
  late ProviderContainer container;

  setUp(() {
    telemetry = FakeTelemetryNotifier(snapshotWith(speedKmh: const Reading(freshness: Freshness.live, value: 0)));
    container = ProviderContainer(overrides: [telemetryProvider.overrideWith(() => telemetry)]);
    container.listen(hmiSurfaceProvider, (_, _) {});
  });

  tearDown(() => container.dispose());

  test('opens settings while parked', () {
    container.read(hmiSurfaceProvider.notifier).open(HmiSurface.settings);
    expect(container.read(hmiSurfaceProvider), HmiSurface.settings);
  });

  test('closes settings as soon as the bike moves above 5 km/h', () {
    container.read(hmiSurfaceProvider.notifier).open(HmiSurface.settings);
    telemetry.emit(snapshotWith(speedKmh: const Reading(freshness: Freshness.live, value: 12)));
    expect(container.read(hmiSurfaceProvider), HmiSurface.dashboard);
  });

  test('refuses to open place search while riding', () {
    telemetry.emit(snapshotWith(speedKmh: const Reading(freshness: Freshness.live, value: 30)));
    container.read(hmiSurfaceProvider.notifier).open(HmiSurface.places);
    expect(container.read(hmiSurfaceProvider), HmiSurface.dashboard);
  });
}
