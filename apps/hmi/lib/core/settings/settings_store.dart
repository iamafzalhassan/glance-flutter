import 'dart:convert';

import 'package:hive_ce/hive.dart';

import 'glance_settings.dart';

abstract interface class SettingsStore {
  Future<GlanceSettings> load();

  Future<void> save(GlanceSettings settings);
}

final class HiveSettingsStore implements SettingsStore {
  static const String boxName = 'glance_settings';
  static const String key = 'settings';

  final Box<String> _box;

  HiveSettingsStore._(this._box);

  static Future<HiveSettingsStore> open() async => HiveSettingsStore._(await Hive.openBox<String>(boxName));

  @override
  Future<GlanceSettings> load() async {
    final raw = _box.get(key);
    if (raw == null) return GlanceSettings.defaults;
    try {
      return GlanceSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return GlanceSettings.defaults;
    }
  }

  @override
  Future<void> save(GlanceSettings settings) => _box.put(key, jsonEncode(settings.toJson()));
}

final class MemorySettingsStore implements SettingsStore {
  GlanceSettings _settings = GlanceSettings.defaults;

  @override
  Future<GlanceSettings> load() async => _settings;

  @override
  Future<void> save(GlanceSettings settings) async => _settings = settings;
}
