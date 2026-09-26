import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../settings/glance_settings.dart';
import '../settings/settings_store.dart';

final settingsStoreProvider = Provider<SettingsStore>((ref) => MemorySettingsStore());

final initialSettingsProvider = Provider<GlanceSettings>((ref) => GlanceSettings.defaults);

final settingsProvider = NotifierProvider<SettingsNotifier, GlanceSettings>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<GlanceSettings> {
  void update(GlanceSettings next) {
    state = next;
    unawaited(ref.read(settingsStoreProvider).save(next));
  }

  @override
  GlanceSettings build() => ref.watch(initialSettingsProvider);
}
