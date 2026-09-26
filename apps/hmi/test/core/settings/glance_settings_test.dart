import 'package:flutter_test/flutter_test.dart';
import 'package:glance/core/settings/glance_settings.dart';
import 'package:glance/core/settings/settings_store.dart';

void main() {
  const custom = GlanceSettings(reduceMotion: true, brightnessFloor: 0.5, fuelPercentPerKm: 0.4, serviceDueKm: 21000, speedAlertKmh: 60, theme: ThemePreference.day);

  test('survives a JSON round trip', () => expect(GlanceSettings.fromJson(custom.toJson()), custom));

  test('falls back to defaults for missing or unknown values', () => expect(GlanceSettings.fromJson({'theme': 'purple'}), GlanceSettings.defaults));

  test('the memory store returns what it saved', () async {
    final store = MemorySettingsStore();
    await store.save(custom);
    expect(await store.load(), custom);
  });
}
