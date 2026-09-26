import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:night_road/night_road.dart';

import 'core/copy/glance_copy.dart';
import 'core/providers/telemetry_providers.dart';
import 'features/hmi/hmi_root.dart';
import 'features/studio/studio_shell.dart';

class GlanceApp extends ConsumerWidget {
  const GlanceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      MaterialApp(debugShowCheckedModeBanner: false, home: ref.watch(appConfigProvider).isStudio ? const StudioShell() : const HmiRoot(), theme: NightRoadTheme.night, title: GlanceCopy.appName);
}
