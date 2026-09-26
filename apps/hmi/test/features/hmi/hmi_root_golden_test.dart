import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glance/core/settings/glance_settings.dart';
import 'package:glance/features/hmi/hmi_root.dart';
import 'package:glance/features/navigation/navigation_providers.dart';
import 'package:glance/features/navigation/navigation_route.dart';
import 'package:glance_protocol/glance_protocol.dart';

import '../../helpers/fake_telemetry.dart';
import '../../helpers/pump_hmi.dart';

void main() {
  const sizes = [Size(1024, 600), Size(1280, 800)];
  const themes = [ThemePreference.night, ThemePreference.day];

  setUpAll(() async {
    final sfPro = FontLoader('packages/night_road/SFProDisplay')
      ..addFont(rootBundle.load('packages/night_road/assets/fonts/SFProDisplay-Regular.otf'))
      ..addFont(rootBundle.load('packages/night_road/assets/fonts/SFProDisplay-Medium.otf'))
      ..addFont(rootBundle.load('packages/night_road/assets/fonts/SFProDisplay-Bold.otf'));
    final icons = FontLoader('MaterialIcons')..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await sfPro.load();
    await icons.load();
  });

  for (final size in sizes) {
    for (final theme in themes) {
      for (final navigating in [false, true]) {
        final name = 'hmi_${navigating ? 'navigating' : 'dashboard'}_${theme.name}_${size.width.round()}x${size.height.round()}';
        testWidgets(name, (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          final telemetry = FakeTelemetryNotifier(snapshotWith(flags: const {TelemetryFlag.ignition, TelemetryFlag.eco, TelemetryFlag.stopStartEnabled, TelemetryFlag.left}));
          await pumpHmi(tester, overrides: [if (navigating) navigationSessionProvider.overrideWith(_GoldenNavigation.new)], telemetry: telemetry, theme: theme);
          await expectLater(find.byType(HmiRoot), matchesGoldenFile('goldens/$name.png'));
        });
      }
    }
  }
}

class _GoldenNavigation extends NavigationSessionNotifier {
  @override
  NavigationSession? build() => NavigationSession(route: NavigationRoute.saved.first, startOdometerM: 18419400);
}
