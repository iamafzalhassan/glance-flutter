import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glance/core/device/no_device_control.dart';
import 'package:glance/core/providers/device_providers.dart';
import 'package:glance/core/providers/settings_providers.dart';
import 'package:glance/core/providers/telemetry_providers.dart';
import 'package:glance/core/providers/vehicle_providers.dart';
import 'package:glance/core/settings/glance_settings.dart';
import 'package:glance/core/vehicle/vehicle_profile.dart';
import 'package:glance/features/hmi/hmi_root.dart';
import 'package:glance_telemetry/glance_telemetry.dart';
import 'package:night_road/night_road.dart';

import 'fake_telemetry.dart';

const VehicleProfile testProfile = VehicleProfile(eco: true, fiWarning: true, highBeam: true, leftIndicator: true, rightIndicator: true, sideStand: true, stopStart: true, maxDisplayKmh: 100, batteryLowMv: 11800, name: 'Test bike');

Future<ProviderContainer> pumpHmi(WidgetTester tester, {required FakeTelemetryNotifier telemetry, List<Override> overrides = const [], ThemePreference theme = ThemePreference.night}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        deviceControlProvider.overrideWithValue(const NoDeviceControl()),
        initialSettingsProvider.overrideWithValue(GlanceSettings.defaults.copyWith(theme: theme)),
        telemetryHubProvider.overrideWithValue(TelemetryHub()),
        telemetryProvider.overrideWith(() => telemetry),
        vehicleProfileProvider.overrideWith((ref) async => testProfile),
        ...overrides,
      ],
      child: MaterialApp(home: const HmiRoot(), theme: NightRoadTheme.night),
    ),
  );
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(HmiRoot)));
}
