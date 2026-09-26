import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glance/core/providers/telemetry_providers.dart';
import 'package:glance/features/ride/widgets/speed_block.dart';
import 'package:glance_telemetry/glance_telemetry.dart';
import 'package:night_road/night_road.dart';

import '../../../helpers/fake_telemetry.dart';

void main() {
  late FakeTelemetryNotifier telemetry;

  Future<void> pumpSpeed(WidgetTester tester, TelemetrySnapshot snapshot) {
    telemetry = FakeTelemetryNotifier(snapshot);
    return tester.pumpWidget(
      ProviderScope(
        overrides: [telemetryProvider.overrideWith(() => telemetry)],
        child: MaterialApp(
          home: const Material(child: Center(child: SpeedBlock())),
          theme: NightRoadTheme.night,
        ),
      ),
    );
  }

  testWidgets('shows the live speed rounded to whole km/h', (tester) async {
    await pumpSpeed(tester, snapshotWith(speedKmh: const Reading(freshness: Freshness.live, value: 42.4)));
    expect(find.text('42'), findsOneWidget);
  });

  testWidgets('never shows the old number when speed is stale', (tester) async {
    await pumpSpeed(tester, snapshotWith(linkUp: false, speedKmh: const Reading(freshness: Freshness.stale, value: 42.4)));
    expect(find.text('42'), findsNothing);
  });

  testWidgets('keeps one size for two and three digits so the numeral never jumps', (tester) async {
    await pumpSpeed(tester, snapshotWith(speedKmh: const Reading(freshness: Freshness.live, value: 42)));
    final twoDigits = tester.getSize(find.byType(SpeedBlock));
    telemetry.emit(snapshotWith(speedKmh: const Reading(freshness: Freshness.live, value: 110)));
    await tester.pumpAndSettle();
    expect(find.text('110'), findsOneWidget);
    expect(tester.getSize(find.byType(SpeedBlock)), twoDigits);
  });

  testWidgets('keeps its size when there is no signal', (tester) async {
    await pumpSpeed(tester, snapshotWith(speedKmh: const Reading(freshness: Freshness.live, value: 42)));
    final live = tester.getSize(find.byType(SpeedBlock));
    telemetry.emit(snapshotWith(linkUp: false, speedKmh: const Reading.missing()));
    await tester.pumpAndSettle();
    expect(find.text('42'), findsNothing);
    expect(tester.getSize(find.byType(SpeedBlock)), live);
  });

  testWidgets('shows no digits before the first frame arrives', (tester) async {
    await pumpSpeed(tester, snapshotWith(linkUp: false, speedKmh: const Reading.missing()));
    expect(find.text('42'), findsNothing);
  });
}
