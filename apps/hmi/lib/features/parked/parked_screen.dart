import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:night_road/night_road.dart';

import '../../core/copy/glance_copy.dart';
import '../../core/format/glance_format.dart';
import '../../core/providers/telemetry_providers.dart';
import '../../core/widgets/clock_text.dart';

class ParkedScreen extends ConsumerWidget {
  const ParkedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fuel = ref.watch(telemetryProvider.select((snapshot) => snapshot.fuelPercent.value));
    final odometer = ref.watch(telemetryProvider.select((snapshot) => snapshot.odometerM.value));
    final colors = context.colors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: ClockText(style: NightRoadType.numSpeed.copyWith(color: colors.textSecondary)),
          ),
          ClockText(
            format: GlanceCopy.date,
            style: NightRoadType.title.copyWith(color: colors.textSecondary),
          ),
          Text(
            GlanceCopy.ignitionOff,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: NightRoadType.body.copyWith(color: colors.textMuted),
          ),
          const SizedBox(height: NightRoadSpacing.xxl),
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: NightRoadSpacing.xxl,
            children: [
              _ParkedValue(label: GlanceCopy.fuel, value: fuel == null ? GlanceCopy.noSignal : GlanceCopy.percent(fuel.round())),
              _ParkedValue(label: GlanceCopy.odometer, value: odometer == null ? GlanceCopy.noSignal : '${GlanceFormat.odometerKm(odometer)} ${GlanceCopy.kmUnit}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ParkedValue extends StatelessWidget {
  const _ParkedValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      NightRoadLabel(label),
      const SizedBox(height: NightRoadSpacing.sm),
      Text(value, maxLines: 1, style: NightRoadType.numMedium.copyWith(color: context.colors.textPrimary)),
    ],
  );
}
