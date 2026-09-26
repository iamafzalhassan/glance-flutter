import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glance/core/copy/glance_copy.dart';
import 'package:glance/features/dashboard/widgets/turn_card.dart';
import 'package:glance/features/navigation/navigation_providers.dart';
import 'package:glance/features/navigation/navigation_route.dart';
import 'package:glance/features/settings/settings_screen.dart';
import 'package:glance_protocol/glance_protocol.dart';
import 'package:glance_telemetry/glance_telemetry.dart';

import '../../helpers/fake_telemetry.dart';
import '../../helpers/pump_hmi.dart';

void main() {
  testWidgets('a critical alert covers the navigation turn card', (tester) async {
    final telemetry = FakeTelemetryNotifier(snapshotWith(flags: const {TelemetryFlag.ignition, TelemetryFlag.fiWarning}));
    await pumpHmi(tester, overrides: [navigationSessionProvider.overrideWith(ActiveNavigation.new)], telemetry: telemetry);
    expect(find.text(GlanceCopy.engineWarning), findsOneWidget);
    final card = find.byType(TurnCard);
    expect(card, findsOneWidget);
    final hit = tester.hitTestOnBinding(tester.getCenter(card));
    final cardBox = tester.renderObject(card);
    expect(hit.path.any((entry) => entry.target == cardBox), isFalse);
  });

  testWidgets('settings open while parked and close as soon as the bike moves', (tester) async {
    final telemetry = FakeTelemetryNotifier(
      snapshotWith(
        flags: const {TelemetryFlag.ignition},
        speedKmh: const Reading(freshness: Freshness.live, value: 0),
      ),
    );
    await pumpHmi(tester, telemetry: telemetry);
    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
    telemetry.emit(
      snapshotWith(
        flags: const {TelemetryFlag.ignition},
        speedKmh: const Reading(freshness: Freshness.live, value: 20),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsNothing);
    expect(find.byIcon(Icons.settings_rounded), findsNothing);
  });

  testWidgets('shows No signal and the no bike signal banner when the link drops', (tester) async {
    final telemetry = FakeTelemetryNotifier(snapshotWith(flags: const {TelemetryFlag.ignition}));
    await pumpHmi(tester, telemetry: telemetry);
    telemetry.emit(snapshotWith(linkUp: false, speedKmh: const Reading(freshness: Freshness.stale, value: 42)));
    await tester.pumpAndSettle();
    expect(find.text(GlanceCopy.noBikeSignalBody), findsOneWidget);
    expect(find.text(GlanceCopy.noSignal), findsWidgets);
    expect(find.text('42'), findsNothing);
  });
}

class ActiveNavigation extends NavigationSessionNotifier {
  @override
  NavigationSession? build() => NavigationSession(route: NavigationRoute.saved.first, startOdometerM: 18419500);
}
