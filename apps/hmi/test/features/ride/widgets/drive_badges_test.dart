import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glance/core/copy/glance_copy.dart';
import 'package:glance/core/providers/telemetry_providers.dart';
import 'package:glance/core/providers/vehicle_providers.dart';
import 'package:glance/features/ride/widgets/drive_badges.dart';
import 'package:glance_protocol/glance_protocol.dart';
import 'package:glance_telemetry/glance_telemetry.dart';
import 'package:night_road/night_road.dart';

import '../../../helpers/fake_telemetry.dart';
import '../../../helpers/pump_hmi.dart';

void main() {
  late FakeTelemetryNotifier telemetry;

  Future<void> pumpBadges(WidgetTester tester, TelemetrySnapshot snapshot) async {
    telemetry = FakeTelemetryNotifier(snapshot);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [telemetryProvider.overrideWith(() => telemetry), vehicleProfileProvider.overrideWith((ref) async => testProfile)],
        child: MaterialApp(
          home: const Material(child: Center(child: DriveBadges())),
          theme: NightRoadTheme.night,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows a single chip centred under the gauge', (tester) async {
    await pumpBadges(tester, snapshotWith(flags: const {TelemetryFlag.eco}));
    expect(find.text(GlanceCopy.eco), findsOneWidget);
    expect(find.text(GlanceCopy.stopStart), findsNothing);
    expect(tester.getCenter(find.byType(NightRoadPill)).dx, closeTo(tester.getCenter(find.byType(DriveBadges)).dx, 0.5));
  });

  testWidgets('keeps the row centred when a second chip slides in', (tester) async {
    await pumpBadges(tester, snapshotWith(flags: const {TelemetryFlag.eco}));
    telemetry.emit(snapshotWith(flags: const {TelemetryFlag.eco, TelemetryFlag.stopStartEnabled}));
    await tester.pumpAndSettle();
    expect(find.byType(NightRoadPill), findsNWidgets(2));
    final left = tester.getRect(find.byType(NightRoadPill).first).left;
    final right = tester.getRect(find.byType(NightRoadPill).last).right;
    expect((left + right) / 2, closeTo(tester.getCenter(find.byType(Center)).dx, 0.5));
  });

  testWidgets('shows the No signal chip when speed is lost', (tester) async {
    await pumpBadges(tester, snapshotWith(linkUp: false, speedKmh: const Reading(freshness: Freshness.stale, value: 30)));
    expect(find.text(GlanceCopy.noSignal), findsOneWidget);
  });

  testWidgets('swaps Stop & Start for Auto stop in place', (tester) async {
    await pumpBadges(tester, snapshotWith(flags: const {TelemetryFlag.stopStartEnabled}));
    telemetry.emit(snapshotWith(flags: const {TelemetryFlag.stopStartEnabled, TelemetryFlag.engineAutoStopped}));
    await tester.pumpAndSettle();
    expect(find.text(GlanceCopy.autoStop), findsOneWidget);
    expect(find.text(GlanceCopy.stopStart), findsNothing);
  });
}
