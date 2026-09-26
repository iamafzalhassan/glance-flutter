import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glance_maps/glance_maps.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/providers/settings_providers.dart';
import 'core/settings/settings_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final store = await HiveSettingsStore.open();
  final settings = await store.load();
  final config = AppConfig.fromEnvironment();
  if (kIsWeb && config.mapsApiKey.isNotEmpty) await loadGoogleMaps(config.mapsApiKey);
  runApp(ProviderScope(overrides: [initialSettingsProvider.overrideWithValue(settings), settingsStoreProvider.overrideWithValue(store)], child: const GlanceApp()));
}
