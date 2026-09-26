import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glance/core/providers/telemetry_providers.dart';
import 'package:glance/features/alerts/critical_alert.dart';
import 'package:glance_protocol/glance_protocol.dart';

import '../../helpers/fake_telemetry.dart';

void main() {
  late FakeTelemetryNotifier telemetry;
  late ProviderContainer container;

  setUp(() {
    telemetry = FakeTelemetryNotifier(snapshotWith(flags: const {TelemetryFlag.fiWarning, TelemetryFlag.lowFuel}));
    container = ProviderContainer(overrides: [telemetryProvider.overrideWith(() => telemetry)]);
    container.listen(criticalAlertProvider, (_, _) {});
  });

  tearDown(() => container.dispose());

  test('raises the engine warning ahead of low fuel', () => expect(container.read(criticalAlertProvider), CriticalAlert.engineWarning));

  test('shows the next alert once the first is dismissed', () {
    container.read(dismissedAlertsProvider.notifier).dismiss(CriticalAlert.engineWarning);
    expect(container.read(criticalAlertProvider), CriticalAlert.lowFuel);
  });

  test('raises a dismissed alert again when its lamp goes off and comes back', () {
    container.read(dismissedAlertsProvider.notifier).dismiss(CriticalAlert.engineWarning);
    container.read(dismissedAlertsProvider.notifier).dismiss(CriticalAlert.lowFuel);
    expect(container.read(criticalAlertProvider), isNull);
    telemetry.emit(snapshotWith());
    expect(container.read(criticalAlertProvider), isNull);
    telemetry.emit(snapshotWith(flags: const {TelemetryFlag.fiWarning}));
    expect(container.read(criticalAlertProvider), CriticalAlert.engineWarning);
  });

  test('raises nothing when every lamp is off', () {
    telemetry.emit(snapshotWith());
    expect(container.read(criticalAlertProvider), isNull);
  });
}
