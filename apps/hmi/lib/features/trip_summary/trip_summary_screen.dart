import 'package:flutter/widgets.dart';
import 'package:night_road/night_road.dart';

import '../../core/copy/glance_copy.dart';
import '../../core/format/glance_format.dart';
import 'ride_summary.dart';

class TripSummaryScreen extends StatelessWidget {
  const TripSummaryScreen({super.key, required this.summary});

  final RideSummary summary;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        GlanceCopy.tripSummary,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: NightRoadType.title.copyWith(color: context.colors.textPrimary),
      ),
      const SizedBox(height: NightRoadSpacing.gutter),
      Expanded(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: NightRoadSpacing.gutter,
          children: [
            _SummaryModule(label: GlanceCopy.tripDistance, unit: GlanceCopy.kmUnit, value: GlanceFormat.tripKm(summary.distanceM)),
            _SummaryModule(label: GlanceCopy.rideTime, unit: '', value: GlanceCopy.rideDuration(summary.duration)),
            _SummaryModule(label: GlanceCopy.average, unit: GlanceCopy.kmh, value: '${summary.averageKmh.round()}'),
            _SummaryModule(label: GlanceCopy.topSpeed, unit: GlanceCopy.kmh, value: '${summary.maxKmh.round()}'),
          ],
        ),
      ),
    ],
  );
}

class _SummaryModule extends StatelessWidget {
  const _SummaryModule({required this.label, required this.unit, required this.value});

  final String label;
  final String unit;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Expanded(
      child: NightRoadModule(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NightRoadLabel(label),
            const SizedBox(height: NightRoadSpacing.sm),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value, maxLines: 1, style: NightRoadType.numLarge.copyWith(color: colors.textPrimary)),
            ),
            Text(
              unit,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: NightRoadType.caption.copyWith(color: colors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
