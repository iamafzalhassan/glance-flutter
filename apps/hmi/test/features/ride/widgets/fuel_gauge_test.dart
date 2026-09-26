import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glance/core/copy/glance_copy.dart';
import 'package:glance/core/providers/telemetry_providers.dart';
import 'package:glance/features/ride/widgets/fuel_gauge.dart';
import 'package:glance_telemetry/glance_telemetry.dart';
import 'package:night_road/night_road.dart';

import '../../../helpers/fake_telemetry.dart';

void main() {
  const gaugeWidth = 240.0;

  Future<void> pumpFuel(WidgetTester tester, Reading<double> fuel) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [telemetryProvider.overrideWith(() => FakeTelemetryNotifier(snapshotWith(fuelPercent: fuel)))],
        child: MaterialApp(
          home: const Material(
            child: Center(
              child: SizedBox(width: gaugeWidth, child: FuelGauge()),
            ),
          ),
          theme: NightRoadTheme.night,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows live fuel without a last known label', (tester) async {
    await pumpFuel(tester, const Reading(freshness: Freshness.live, value: 62));
    expect(find.text(GlanceCopy.percent(62)), findsOneWidget);
    expect(find.text(GlanceCopy.lastKnown), findsNothing);
  });

  testWidgets('greys stale fuel and labels it last known', (tester) async {
    await pumpFuel(tester, const Reading(freshness: Freshness.stale, value: 55));
    expect(find.text(GlanceCopy.percent(55)), findsOneWidget);
    expect(find.text(GlanceCopy.lastKnown), findsOneWidget);
  });

  testWidgets('shows No signal when fuel was never received', (tester) async {
    await pumpFuel(tester, const Reading.missing());
    expect(find.text(GlanceCopy.noSignal), findsOneWidget);
  });
}
