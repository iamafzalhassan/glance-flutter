import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:night_road/night_road.dart';

import '../../core/providers/device_providers.dart';
import '../../core/providers/telemetry_providers.dart';
import '../../core/widgets/clock_text.dart';
import '../ride/widgets/tell_tale_row.dart';

class StatusBar extends ConsumerWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linkUp = ref.watch(telemetryProvider.select((snapshot) => snapshot.linkUp));
    final hot = ref.watch(overheatedProvider);
    final colors = context.colors;
    return SizedBox(
      height: NightRoadSpacing.statusBar,
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: ClockText(style: NightRoadType.caption.copyWith(color: colors.textSecondary)),
            ),
          ),
          const TellTaleRow(),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: NightRoadSpacing.md,
              children: [
                if (hot) Icon(Icons.device_thermostat_rounded, color: colors.stateWarn, size: NightRoadSpacing.icon),
                Icon(linkUp ? Icons.cable_rounded : Icons.link_off_rounded, color: linkUp ? colors.textMuted : colors.stateDanger, size: NightRoadSpacing.icon),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
