import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:night_road/night_road.dart';

import '../../../core/copy/glance_copy.dart';
import '../../../core/format/glance_format.dart';
import '../../../core/providers/telemetry_providers.dart';

class OdometerLine extends ConsumerWidget {
  const OdometerLine({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reading = ref.watch(telemetryProvider.select((snapshot) => snapshot.odometerM));
    final colors = context.colors;
    final value = reading.value;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        const Expanded(child: NightRoadLabel(GlanceCopy.odometer)),
        value == null
            ? Text(
                GlanceCopy.noSignal,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: NightRoadType.body.copyWith(color: colors.textMuted),
              )
            : Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      style: NightRoadType.numMedium.copyWith(color: reading.isLive ? colors.textPrimary : colors.textMuted),
                      text: GlanceFormat.odometerKm(value),
                    ),
                    TextSpan(
                      style: NightRoadType.caption.copyWith(color: colors.textMuted),
                      text: ' ${GlanceCopy.kmUnit}',
                    ),
                  ],
                ),
                maxLines: 1,
              ),
      ],
    );
  }
}
