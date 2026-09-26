import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../device/theme_policy.dart';
import '../settings/glance_settings.dart';
import 'device_providers.dart';
import 'settings_providers.dart';
import 'telemetry_providers.dart';

enum DisplayTheme { night, day }

enum HmiSurface { dashboard, settings, places }

final displayThemeProvider = NotifierProvider<DisplayThemeNotifier, DisplayTheme>(DisplayThemeNotifier.new);

final hmiSurfaceProvider = NotifierProvider<HmiSurfaceNotifier, HmiSurface>(HmiSurfaceNotifier.new);

class DisplayThemeNotifier extends Notifier<DisplayTheme> {
  @override
  DisplayTheme build() {
    final preference = ref.watch(settingsProvider.select((settings) => settings.theme));
    if (preference == ThemePreference.night) return DisplayTheme.night;
    if (preference == ThemePreference.day) return DisplayTheme.day;
    ref.listen(ambientLuxProvider, (_, next) {
      final lux = next.value;
      if (lux != null) state = ThemePolicy.standard.next(lux, state);
    });
    final lux = ref.read(ambientLuxProvider).value;
    return lux == null ? DisplayTheme.night : ThemePolicy.standard.next(lux, DisplayTheme.night);
  }
}

class HmiSurfaceNotifier extends Notifier<HmiSurface> {
  void close() => state = HmiSurface.dashboard;

  void open(HmiSurface surface) {
    if (!ref.read(telemetryProvider).ridingLocked) state = surface;
  }

  @override
  HmiSurface build() {
    ref.listen(telemetryProvider.select((snapshot) => snapshot.ridingLocked), (_, locked) {
      if (locked) state = HmiSurface.dashboard;
    });
    return HmiSurface.dashboard;
  }
}
