import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:night_road/night_road.dart';

import '../../../core/providers/display_providers.dart';
import '../../../core/providers/telemetry_providers.dart';

class ParkedActions extends ConsumerWidget {
  const ParkedActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parked = !ref.watch(telemetryProvider.select((snapshot) => snapshot.ridingLocked));
    final surfaces = ref.read(hmiSurfaceProvider.notifier);
    return IgnorePointer(
      ignoring: !parked,
      child: AnimatedOpacity(
        curve: NightRoadMotion.standardCurve,
        duration: NightRoadMotion.of(context, NightRoadMotion.standard),
        opacity: parked ? 1 : 0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: NightRoadSpacing.sm,
          children: [
            NightRoadRoundButton(icon: Icons.settings_rounded, onPressed: () => surfaces.open(HmiSurface.settings), size: NightRoadSpacing.touch),
            NightRoadRoundButton(icon: Icons.search_rounded, onPressed: () => surfaces.open(HmiSurface.places), size: NightRoadSpacing.touch),
          ],
        ),
      ),
    );
  }
}
